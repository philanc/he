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

local flush = io.flush
------------------------------------------------------------------------
--display functions

local style = {
	normal = function() color(col.normal) end, 
	high = function() color(col.red, col.bold) end, 
	msg = function() color(col.normal); color(col.green) end, 
	reverse = function() color(col.reverse) end, 
	bckg = function() color(col.black, col.bgyellow) end, 
}

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
	flush()
end

local function boxfill(b, ch, stylefn)
	local filler = rep(ch, b.c)
	for i = 1, b.l do
		stylefn()
		go(b.x+i-1, b.y)
		out(filler)
	end
	style.normal() -- back to notmal style
	flush()
end

------------------------------------------------------------------------
-- editor is the global editor object
local editor = {
	quit = false, -- set to true to quit editor_loop()
	nextk = term.input(), -- the "read next key" function
}


-- buf is the current buffer
local buf = {}


local function bufnew(ll)
	-- ll is a list of lines
	local buf = { 
		ll=ll,  -- list of text lines
		ci=1, cj=0,   -- text cursor (line ci, offset cj)
		li=1,      -- index in ll of the line at the top of the box
		chgd=true, -- true if buffer has changed since last display
		styf=style.normal,  --style function
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

local function redisplay(full)
	if full then
		editor.scrl, editor.scrc = term.getscrlc()
		-- [editor.scrbox is a bckgnd box with a pattern to
		-- visually check that edition does not overflow buf box]
		editor.scrbox = boxnew(1, 1, editor.scrl, editor.scrc)
		boxfill(editor.scrbox, NDC, style.bckg)
		buf.box = boxnew(3, 4, editor.scrl-4, editor.scrc-6)
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

------------------------------------------------------------------------
-- dialog functions

local function pad(s, w) 
	-- pad a string to fit width w
	if #s >= w then return s:sub(1,w) end
	return s .. rep(' ', w-#s)
end

local function msg(buf, m)
	-- display a message m on last screen line
	m = pad(m, editor.scrc)
	go(editor.scrl, 1); cleareol(); style.msg()
	out(m); style.normal(); flush()
end

------------------------------------------------------------------------
-- buffer utility functions

-- test if at end / beginning of  line  (eol, bol)
local function ateol(buf) return buf.cj >= #buf.ll[buf.ci] end
local function atbol(buf) return buf.cj <= 0 end
-- test if at  end / beginning of  text (eot, bot)
local function ateot(buf) return (buf.ci == #buf.ll) and ateol(buf) end
local function atbot(buf) return (buf.ci == 1) and atbol(buf) end

------------------------------------------------------------------------
-- editor actions

local function adown()
	buf.ci = min(buf.ci + 1, #buf.ll)
end

local function aup()
	buf.ci = max(buf.ci - 1, 1)
end

local function ahome()
	buf.cj = 0
end

local function aend()
	buf.cj = #buf.ll[buf.ci]
end

local function aright()
	if ateot(buf) then return end
	if ateol(buf) then ahome(buf); adown(buf)
	else buf.cj = buf.cj + 1 end
end
	
local function aleft()
	-- at eol, cj maybe larger than #l when going 
	-- up or down from longer lines
	buf.cj = min(buf.cj, #buf.ll[buf.ci])
	if atbot(buf) then return end
	if atbol(buf) then aup(buf); aend(buf)
	else buf.cj = buf.cj - 1  end
end

local function apgdn()
	buf.ci = min(buf.ci + (buf.box.l - 2), #buf.ll)
end

local function apgup()
	buf.ci = max(buf.ci - (buf.box.l - 2), 1)
end

local function anl()
	local l = buf.ll[buf.ci]
	table.insert(buf.ll, buf.ci, l:sub(1, buf.cj))
	buf.ll[buf.ci + 1] = l:sub(buf.cj + 1)
	buf.ci = buf.ci + 1
	buf.cj = 0
	buf.chgd = true
end

local function adel()
	local ci, cj = buf.ci, buf.cj
	local l = buf.ll[ci]
	if ateol(buf) then
		local l1 = buf.ll[ci+1]
		if not l1 then return end -- at eot
		table.remove(buf.ll, ci+1)
		buf.ll[ci] = l .. l1
	else
		buf.ll[ci] = l:sub(1,cj) .. l:sub(cj+2)
	end
	buf.chgd = true
end

local function abksp()
	if atbot(buf) then return end
	aleft(buf) ; adel(buf)
end

local function ainsch(k)
	local ci, cj = buf.ci, buf.cj
	local l = buf.ll[ci]
	buf.ll[ci] = l:sub(1, cj) .. char(k) .. l:sub(cj+1)
	buf.cj = cj + 1
	buf.chgd = true
end

local function openfile()
end

------------------------------------------------------------------------
-- bindings

local edit_actions = { -- actions binding for text edition
	[1] = ahome,   -- ^A
	[2] = aleft,   -- ^B
	[4] = adel,    -- ^D
	[5] = aend,    -- ^E
	[6] = aright,  -- ^F
	[8] = abksp,   -- ^H
	[12] = function() redisplay(true) end, -- ^L
	[13] = anl,    -- ^M (insert newline)
	[14] = adown,  -- ^N
	[16] = aup,    -- ^P
	[17] = function() editor.quit = true end, -- ^Q
	--
	[keys.kpgup] = apgup,
	[keys.kpgdn] = apgdn,
	[keys.khome] = ahome,
	[keys.kend] = aend,
	[keys.kdel] = adel, 
	[keys.del] = abksp, 
	[keys.kright] = aright,
	[keys.kleft] = aleft,
	[keys.kup] = aup,
	[keys.kdown] = adown,

}--edit_actions

function editor_loop()
	tl = he.fgetlines'zztest' -- [testfile. no file open for the moment]
	style.normal()
	buf = bufnew(tl)
	buf.actions = edit_actions
	redisplay(true)
	while not editor.quit do
		local k = editor.nextk()
--~ 		if k == 17 then break end -- ^Q quits
		msg(buf, term.keyname(k))
		local act = buf.actions[k]
		if act then 
			act()
		elseif (k >= 32 and k < 127) 
			or (k >= 160 and k < 256) 
			or (k == 9) then
			ainsch(k)
		else
			msg(buf, term.keyname(k) .. " not bound")
		end
	redisplay()
	end--while true
end

function main()
	-- set term in raw mode
	local prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	term.reset()
	-- run the application
	local ok, msg = xpcall(editor_loop, debug.traceback)
--~ 	local ok, msg = xpcall(edit, debug.debug, [edit args...])

	-- restore terminal in a a clean state
	term.show() -- show cursor
	term.left(999); term.down(999)
	style.normal()
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

