-- editfile.lua

------------------------------------------------------------------------

local he = require"he"
he.interactive()
local ln = require"linenoise"
local term = require "term"

-- some local definitions

local strf = string.format
local byte, char, rep = string.byte, string.char, string.rep
local app, concat = table.insert, table.concat

local repr = function(x) return strf("%q", tostring(x)) end
local max = function(x, y) if x < y then return y else return x end end 
local min = function(x, y) if x < y then return x else return y end end 

local out, outf, outdbg = term.out, term.outf, term.outdbg
local go, cleareol, color = term.golc, term.cleareol, term.color
local col, keys = term.colors, term.keys

------------------------------------------------------------------------

local style = {
	[1] = function() color(col.normal) end, 
	[2] = function() color(col.red, col.bold) end, 
	[3] = function() color(col.normal); color(col.green) end, 
	[5] = function() color(col.red, col.bgblack) end, 
	[7] = function() color(col.black, col.bgyellow) end, 
}

local put = function(l, c, y, s) -- y is style number
	go(l, c); style[y](); outf(s)
end

local puteol = function(l, c, y, s) -- y is style number
	go(l, c); cleareol(); style[y](); outf(s)
end

-- box :: {x, y, l, c}  -- topleft is (x,y), l lines, c columns

local function boxnew(x, y, l, c)
	local b = {x=x, y=y, l=l, c=c}
	b.clrl = rep(" ", c) -- used to clear box content
	return b
end

local function boxclear(b)
	for i = 1, l do 
		go(b.x+i-1, b.y)
		out(b.clrl)
	end
end

local quit = false
local tabln = 4
local EOL = char(187) -- >>, indicate more undisplayed chars in s
local NDC = char(183) -- middledot, used for non-displayable latin1 chars
local EOT = '~'  -- used to indicate that we are past the end of text


local function ccrepr(b, j)
	-- return display representation of char with code b
	-- at line offset j (used for tabs)
	local s
	if b == 9 then s = rep(' ', tabln - j % tabln)
	elseif (b >= 127 and b <160) or (b < 32) then s = NDC
	else s = char(b)
	end--if
	return s
end --ccrepr

local function boxline(b, bl, s)
	-- display s at the bl-th line of box b
	-- if s is tool long for the box, return the
	-- index of the first undisplayed char in s
	local bc = b.c
	local cc = 0 --curent col in box
	go(b.x+bl-1, b.y); out(b.clrl)
	go(b.x+bl-1, b.y)
	for i = 1, #s do
		local chs = ccrepr(byte(s, i), cc)
		cc = cc + #chs
		if cc >= bc then 
			go(b.x+bl-1, b.y+b.c-1)
			outf(EOL)
			return i -- index of first undisplayed char in s
		end
		out(chs)
	end
end --boxline

local function boxlines(b, ll, li)
	-- display lines starting at index li in list of lines ll
	for i = 1, b.l do
		local l = ll[li+i-1] or EOT
		boxline(b, i, l)
	end
	io.flush()
end

local function boxfill(b, ch, styleno)
	local filler = rep(ch, b.c)
	for i = 1, b.l do
		style[styleno]()
		go(b.x+i-1, b.y)
		out(filler)
	end
	style[1]() -- back to notmal style
	io.flush()
end
		
		
local function pad(s, col)
	if #s >= col then return s:sub(1,col) end
	return s .. rep(' ', col-#s)
end

function disptitle(title, l, w) puteol(l, 1, 3, pad(title, w)) end	
function dispmsg(msg, l, w) puteol(l, 1, 3, pad(msg, w)) end	


local function bufnew(ll)
	-- ll is a list of lines
	local buf = { 
		ll=ll,  -- list of text lines
		ci=1, cj=0,   -- text cursor (line ci, offset cj)
		li=1,      -- index in ll of the line at the top of the box
		chgd=true, -- true if buffer has changed since last display
		styf=style[1],  --style function
	}
	return buf
end

local function adjcursor(buf)
	if buf.chgd then return end 
	local bl = buf.box.l
	if buf.ci < buf.li or buf.ci >= buf.li+bl then 
		-- cursor has moved out of box.
		-- set li so that ci is in the middle of the box
		buf.li = max(1, buf.ci-bl//2) 
		buf.chgd = true
		return
	end
	-- here, assume that cursor will move within the box
	local cx = buf.ci - buf.li + 1
	local cy = 1
	local col = buf.box.c
	local l = buf.ll[buf.ci]
	for j = 1, buf.cj do
		local b = byte(l, j)
		if not b then break end
		if b == 9 then cy = cy + (tabln - (cy-1) % tabln)
		else cy = cy + 1 
		end
		if cy > col then --don't move beyond the right of the box
			cy = col
			buf.cj = j
			break
		end
	end
	go(buf.box.x + cx - 1, buf.box.y + cy - 1); io.flush()
end -- adjcursor

local function bufredisplay(buf, full)
	if full then
		buf.scrl, buf.scrc = term.getscrlc()
		buf.scrbox = boxnew(1, 1, buf.scrl, buf.scrc)
		boxfill(buf.scrbox, NDC, 7)
		buf.box = boxnew(3, 4, buf.scrl-4, buf.scrc-6)
		buf.chgd = true
	end
	adjcursor(buf)
	if buf.chgd then
		boxlines(buf.box, buf.ll, buf.li)
		buf.chgd = false
		adjcursor(buf)
	end
	buf.chgd = false
end --bufredisplay

local function msg(buf, m)
	dispmsg(m, buf.scrl, buf.scrc)
	style[1](); io.flush()
end
------------------------------------------------------------------------
-- editor actions

	
local function adown(buf)
	buf.ci = min(buf.ci + 1, #buf.ll)
end

local function aup(buf)
	buf.ci = max(buf.ci - 1, 1)
end

local function ahome(buf)
	buf.cj = 0
end

local function aend(buf)
	buf.cj = #buf.ll[buf.ci]
end

local function aright(buf)
	buf.cj = buf.cj + 1
	if buf.cj > #buf.ll[buf.ci] then
		ahome(buf); adown(buf)
	end
end
	
local function aleft(buf)
	-- at eol, cj maybe larger than #l when going 
	-- up or down from longer lines
	buf.cj = min(buf.cj, #buf.ll[buf.ci])
	buf.cj = buf.cj - 1
	if buf.cj < 0 then
		aup(buf); aend(buf)
	end
end

local function apgdn(buf)
	buf.ci = min(buf.ci + (buf.box.l - 2), #buf.ll)
end


local function apgup(buf)
	buf.ci = max(buf.ci - (buf.box.l - 2), 1)
end

local actions = {
	[17] = function(buf) quit = true end, -- ^Q
	[16] = function(buf) msg(buf, "Hello!") end, -- ^P
	[12] = function(buf) bufredisplay(buf, true) end, -- ^L
	[keys.khome] = ahome,
	[keys.kend] = aend,
	[keys.kright] = aright,
	[keys.kleft] = aleft,
	[keys.kup] = aup,
	[keys.kdown] = adown,
	[keys.kpgup] = apgup,
	[keys.kpgdn] = apgdn,

}--actions

function t5()
	nextk = term.input()
	tl = he.fgetlines'zztest'
--~ 	tl = { "ab\9def\9g\9hij", "lmno" }
	style[1]()
	tbuf = bufnew(tl)
	bufredisplay(tbuf, true)
	while not quit do
		local k = nextk()
		if k == byte'Q'-64 then break end
		msg(tbuf, term.keyname(k))
		local act = actions[k]
		if act then act(tbuf) end
	bufredisplay(tbuf)
	end--while true
end

function main()
	-- set term in raw mode
	local prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	term.reset()
--~ 	term.hide()
	-- run the application
	local ok, msg = xpcall(t5, debug.traceback)
--~ 	local ok, msg = xpcall(ta.runapp, debug.debug, ta, app)

	-- restore terminal in a a clean state
	term.show() -- show cursor
	term.left(999); term.down(999)
	style[1]()
	io.flush()
	--~ 	ln.setmode(omode)
	term.restoremode(prevmode)
--~ 	print(prevmode)
	if not ok then 
		print(msg)
		os.exit(1)
	end
end

main()

