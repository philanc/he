-- viewfile.lua

------------------------------------------------------------------------
-- some local definitions

local strf = string.format
local byte, char, rep = string.byte, string.char, string.rep
local spack, sunpack = string.pack, string.unpack
local app, concat = table.insert, table.concat

local repr = function(x) return strf("%q", tostring(x)) end
local max = function(x, y) if x < y then return y else return x end end 
local min = function(x, y) if x < y then return x else return y end end 

------------------------------------------------------------------------
local term = require "term"

local out = term.out
local outf = term.outf
local outdbg = term.outdbg
local keys = term.keys

------------------------------------------------------------------------
local he = require"he"
he.interactive()
ln = require"linenoise"

local sl, sc -- screen lines, columns
local out, go, color = term.out, term.golc, term.color
local cleareol = term.cleareol
local col = term.colors

local sf = string.format
local flush = io.flush

local put = function(l, c, s)
	go(l, c); out(s)
end

local style = {
	[1] = function() color(col.normal) end, 
	[2] = function() color(col.red, col.bold) end, 
	[3] = function() color(col.green) end, 
	[5] = function() color(col.red, col.bgblack) end, 
}

local put = function(l, c, y, s) -- y is style number
	go(l, c); style[y](); outf(s)
end

local puteol = function(l, c, y, s) -- y is style number
	go(l, c); cleareol(); style[y](); outf(s)
end

local coord = function(l, c) return sf("l=%d c=%d", l, c) end

tabln = 8

local function brep3(b, li)
	-- return the screen representation of ascii b at line index li and
	-- the new line index
	local s
	local pre = char(215) -- latin1 mult sign
	if b == 9 then s = rep(' ', tabln - li%tabln)
	elseif (b >= 127 and b <160) or (b < 32) then s = strf('%s%02x', pre, b) 
	else s = char(b)
	end
	return s, li + #s
end --brep

local function brep2(b, li)
	-- return the screen representation of ascii b at line index li and
	-- the new line index
	local s
	local ndc = char(183) -- latin1 centered dot
	if b == 9 then s = rep(' ', tabln - li%tabln)
	elseif b >= 127 and b <160 then s = ndc
	elseif b < 32 then s = ndc
	else s = char(b)
	end
	return s, li + #s
end --brep

local function brep1(b, li)
	-- return the screen representation of ascii b at line index li and
	-- the new line index
	local s
	local ndc = char(183) -- latin1 centered dot
	if b == 9 then s = rep(' ', tabln - li%tabln)
	elseif b == 127 then s = ndc
	elseif b < 32 then s = ndc
	else s = char(b)
	end
	return s, li + #s
end --brep

local function brep0(b, li)
	-- return the screen representation of ascii b at line index li and
	-- the new line index
	local s
	if b == 9 then s = rep(' ', tabln - li%tabln)
	elseif b == 127 then s = '^?'
	elseif b < 32 then s = '^' .. char(b+64)
	else s = char(b)
	end
	return s, li + #s
end --brep

local brep = brep2

local function reflow(txt, col)
	-- read all chars in txt, place them in display lines
	-- (max length = col). return the list of display lines
	local txtl = list() -- the list of display lines
	local dll = list() -- a display line as a list of chars or small strings
	local dl -- display line as a string (#dl <= col)
	local b, c, s
	local i, li = 1, 0
	for i = 1, #txt do
		b = byte(txt, i)
		if b == 10 then --newline
			dl = concat(dll)
			txtl:app(dl)
			dll = list()
			li = 1		
		else
			s, li = brep(b, li)
			if li > col then
				dl = concat(dll)
				txtl:app(dl)
				dll = list()
				li = #s
			end
			dll:app(s)
		end -- if newline
	end
	dl = concat(dll) --finalize the last line
	txtl:app(dl)
	return txtl
end --reflow

function displines(txtl, li, maxl)
	-- display lines at index li in txtl
	-- display at most maxl lines
	topl = 2 -- display starting at screenline 2
	for i = topl, topl + maxl - 1 do
		local sl = txtl[li]
		if sl then puteol(i, 1, 1, sl)
		else puteol(i, 1, 1, '~')
		end
		li = li + 1
	end
end

local function pad(s, col)
	if #s >= col then
		s = s:sub(1,col)
	else
		s = s .. rep(' ', col - #s)
	end
	return s
end

function disptitle(title, col)
	puteol(1, 1, 3, pad(title, col))
end	

function dispmsg(msg, col)
	puteol(scrl, 1, 3, pad(msg, col))
end	

function display(txt)
--~ 	omode = ln.getmode()
--~ 	ln.setrawmode()
--~ 	os.execute("stty raw -echo 2> /dev/null")
	local prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	nextk = term.input()
	while true do
		term.reset()
		term.hide()
		scrl, scrc = term.getscrlc()
		disptitle("viewfile:", scrc)
		local help = "Quit: ^Q, Redisplay: ^L,  "
		.. "Navigation: PgUp, PgDown, Home, End"
		dispmsg(help, scrc)
		local txtl = reflow(txt, scrc)
		local li = 1
		displines(txtl, li, scrl-2)
		while true do
			k = nextk()
			if k == byte'Q'-64 then break
			elseif k == byte'L'-64 then goto continue
			elseif k == keys.kpgup and li > 1 then
				li = max(li - (scrl - 3), 1)
				displines(txtl, li, scrl-2)
			elseif k == keys.kpgdn and li < #txtl then
				li = min(li + (scrl - 3), #txtl)
				displines(txtl, li, scrl-2)
			elseif k == keys.khome then
				li = 1
				displines(txtl, li, scrl-2)
			elseif k == keys.kend then
				li = max(#txtl - (scrl-3), 1)
				displines(txtl, li, scrl-2)
			else
--~ 				puteol(scrl, 1, 2, term.keyname(k))
			end
		end
		break
		::continue::
	end
	term.show() -- show cursor
	go(scrl, 1); style[1](); cleareol(); flush()
--~ 	ln.setmode(omode)
--~ 	os.execute("stty sane")
	term.restoremode(prevmode)
end --display

function t3()

--~ 	txt = rep('\1',80) .. rep('\2',80)
--~ 	txt = rep('\1\2\3\9',80)
--~ 	txt = rep('\1\9\1\2\9\1\2\3\9',80)
--~ 	pp(reflow(txt, 80))

	brep = brep2 -- (use middledot for non latin1-printable chars)
	filename = arg[1]
	txt, msg = he.fget(filename)
	if not txt then
		print(msg); os.exit(1)
	end
	display(txt)
end

t3()

