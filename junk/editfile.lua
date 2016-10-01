-- editfile.lua
-- !!! WORK IN PROGRESS !!!
-- @@@@ cursor and display bug when wipe/yank many lines (more than fit in scr)
------------------------------------------------------------------------

local he = require"he"
he.interactive()
local ln = require"linenoise"
local term = require "term"

-- some local definitions

local strf = string.format
local byte, char, rep = string.byte, string.char, string.rep
local app, concat = table.insert, table.concat

local function repr(x) return strf("%q", tostring(x)) end
local function max(x, y) if x < y then return y else return x end end 
local function min(x, y) if x < y then return x else return y end end 

local function pad(s, w) -- pad a string to fit width w
	if #s >= w then return s:sub(1,w) else return s .. rep(' ', w-#s) end
end

local out, outf, outdbg = term.out, term.outf, term.outdbg
local go, cleareol, color = term.golc, term.cleareol, term.color
local col, keys = term.colors, term.keys

local flush = io.flush

local function readfile(fn)
	fh, errm = io.open(fn)
	if not fh then return nil, errm end
	local ll = {}
	for l in fh:lines() do table.insert(ll, l) end
	fh:close()
	return ll
end
	


------------------------------------------------------------------------
--display functions  (styles, boxes, line display)

local style = {
	normal = function() color(col.normal) end, 
	high = function() color(col.red, col.bold) end, 
	status = function() color(col.red, col.bold) end, 
	msg = function() color(col.normal); color(col.green) end, 
--~ 	sel = function() color(col.reverse) end, 
	sel = function() color(col.magenta, col.bold) end, 
	bckg = function() color(col.black, col.bgyellow) end, 
}

local function boxnew(x, y, l, c)
	-- a box is a rectangular area on the screen
	-- defined by top left corner (x, y) 
	-- and number of lines and columns (l, c)
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

local function boxfill(b, ch, stylefn)
	local filler = rep(ch, b.c)
	stylefn()
	for i = 1, b.l do
		go(b.x+i-1, b.y); out(filler)
	end
	style.normal() -- back to notmal style
	flush()
end

-- line display

local tabln = 4
local EOL = char(187) -- >>, indicate more undisplayed chars in s
local NDC = char(183) -- middledot, used for non-displayable latin1 chars
local EOT = '~'  -- used to indicate that we are past the end of text


local function ccrepr(b, j)
	-- return display representation of char with code b
	-- at line offset j (j is used for tabs)
	local s
	if b == 9 then s = rep(' ', tabln - j % tabln)
	elseif (b >= 127 and b <160) or (b < 32) then s = NDC
	else s = char(b)
	end--if
	return s
end --ccrepr

local function boxline(b, bl, l, insel, jon, joff)
	-- display line l at the bl-th line of box b
	-- if s is tool long for the box, return the
	-- index of the first undisplayed char in l
	-- insel: true if line start is in the selection
	-- jon: if defined and not insel, position of beg of selection
	-- joff: if defined, position of end of selection
	local bc = b.c
	local cc = 0 --curent col in box
	go(b.x+bl-1, b.y); out(b.clrl)
	go(b.x+bl-1, b.y)
	if insel then style.sel() end
	for j = 1, #l do
		if (not insel) and j == jon+1 then style.sel(); insel=true end
		if insel and j == joff+1 then style.normal() end
		local chs = ccrepr(byte(l, j), cc)
		cc = cc + #chs
		if cc >= bc then 
			go(b.x+bl-1, b.y+b.c-1)
			outf(EOL)
			style.normal()
			return j -- index of first undisplayed char in s
		end
		out(chs)
	end
	style.normal()
end --boxline


------------------------------------------------------------------------
-- editor is the global editor object
local editor = {
	quit = false, -- set to true to quit editor_loop()
	nextk = term.input(), -- the "read next key" function
	buflist = {},  -- list of buffers
}


------------------------------------------------------------------------
-- dialog functions

local function status(m)
	m = pad(m, editor.scrc)
	go(1, 1); cleareol(); style.status()
	out(m); style.normal(); flush()
end

local function msg(m)
	-- display a message m on last screen line
	m = pad(m, editor.scrc)
	go(editor.scrl, 1); cleareol(); style.msg()
	out(m); style.normal(); flush()
end

local function readstr(prompt)
	-- display prompt, read a string on the last screen line
	-- [read only ascii or latin1 printable chars - no tab]
	-- [ no edition except bksp ]
	-- if ^G then return nil
	local s = ""
	msg(prompt)
	while true do
		go(editor.scrl, #prompt+1); cleareol(); outf(s)	-- display s
		k = editor.nextk()
		if (k >= 32 and k <127) or (k >=160 and k < 256) then
			s = s .. char(k) 
		elseif k == 8 or k == keys.del then -- backspace
			s = s:sub(1, -2)
		elseif k == 13 then return s  -- return
		elseif k == 7 then return nil -- ^G - abort
		else -- ignore all other keys
		end
	end--while
end --readstr

------------------------------------------------------------------------
-- buf is the current buffer
local buf = {}

local function statusline()
	local s = strf("[%d:%d] ", buf.ci, buf.cj)
	if buf.si then s = s .. strf("[%d:%d] ", buf.si, buf.sj) end
	s = s .. strf("li=%d ", buf.li)
	return s
end--statusline

local function bufnew(ll)
	-- ll is a list of lines
	local buf = { 
		ll=ll,  -- list of text lines
		ci=1, cj=0,   -- text cursor (line ci, offset cj)
		li=1,      -- index in ll of the line at the top of the box
		chgd=true, -- true if buffer has changed since last display
		curstack = { {1, 0} } -- cursor stack (for push,pop opns)
	}
	table.insert(editor.buflist, buf)
	return buf
end

local function adjcursor(buf)
	-- first, adjust buf.li
	local bl = buf.box.l
	if buf.ci < buf.li or buf.ci >= buf.li+bl then 
		-- cursor has moved out of box.
		-- set li so that ci is in the middle of the box
		buf.li = max(1, buf.ci-bl//2) 
		buf.chgd = true
	end
	if buf.chgd then return end -- (adjusted li or real content change)
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
	status(statusline())
	go(buf.box.x + cx - 1, buf.box.y + cy - 1); flush()
end -- adjcursor


local function displaylines(buf)
	-- display lines starting at index buf.li in list of lines buf.ll
	local b, ll, li = buf.box, buf.ll, buf.li
	local ci, cj, si, sj = buf.ci, buf.cj, buf.si, buf.sj
	local bi, bj, ei, ej
	local sel, insel, jon, joff = false, false, -1, -1
	if si then
		sel = true
		if si < ci then bi=si; bj=sj; ei=ci; ej=cj
		elseif si > ci then bi=ci; bj=cj; ei=si; ej=sj
		elseif sj < cj then bi=si; bj=sj; ei=ci; ej=cj
		elseif sj >= cj then bi=ci; bj=cj; ei=si; ej=sj
		end
	end
	for i = 1, b.l do
		local lx = li+i-1
		if sel then
			insel, jon, joff = false, -1, -1
			if lx > bi and lx < ei then insel=true
			elseif lx == bi and lx == ei then jon=bj; joff=ej
			elseif lx == bi then jon=bj
			elseif lx == ei then joff=ej; insel=true
			end
		end
		local l = ll[lx] or EOT
		boxline(b, i, l, insel, jon, joff)
	end
	flush()
end

local function redisplay(buf)
	adjcursor(buf)
	if buf.chgd or buf.si then
		displaylines(buf)
		buf.chgd = false
		adjcursor(buf)
	end
	buf.chgd = false
end --redisplay


local function fullredisplay()
	editor.scrl, editor.scrc = term.getscrlc()
	-- [editor.scrbox is a bckgnd box with a pattern to
	-- visually check that edition does not overflow buf box]
	editor.scrbox = boxnew(1, 1, editor.scrl, editor.scrc)
	boxfill(editor.scrbox, NDC, style.bckg)
	buf.box = boxnew(2, 2, editor.scrl-3, editor.scrc-2)
	buf.chgd = true
	redisplay(buf)
end --fullredisplay

------------------------------------------------------------------------
-- buffer utility functions
-- use these functions instead of direct buf.ll manipulation. 
-- This will make it easier to change or enrich the 
-- representation later. (eg. syntax coloring, undo/redo, ...)

-- test if at end / beginning of  line  (eol, bol)
local function ateol() return buf.cj >= #buf.ll[buf.ci] end
local function atbol() return buf.cj <= 0 end
-- test if at  first or last line of text
local function atfirst() return (buf.ci <= 1) end
local function atlast() return (buf.ci >= #buf.ll) end
-- test if at  end or beginning of  text (eot, bot)
local function ateot() return atlast() and ateol() end
local function atbot() return atfirst() and atbol() end

local function markbeforecur()
	return (buf.si < buf.ci) or (buf.si == buf.ci and buf.sj < buf.cj)
end

local function getcur() return buf.ci, buf.cj end
local function getsel() return buf.si, buf.sj end
local function pushcur() 
	table.insert(buf.curstack, {buf.ci, buf.cj, buf.si, buf.sj})
end
local function popcur()
	local ct = table.remove(buf.curstack)
	if not ct then return end -- nothing left in curstack: do nothing
	buf.ci, buf.cj, buf.si, buf.sj = table.unpack(ct)
end

local function getselbounds()
	if buf.si then
		local ci, cj, si, sj = buf.ci, buf.cj, buf.si, buf.sj
		local bi, bj, ei, ej
		if si < ci then bi=si; bj=sj; ei=ci; ej=cj
		elseif si > ci then bi=ci; bj=cj; ei=si; ej=sj
		elseif sj < cj then bi=si; bj=sj; ei=ci; ej=cj
		else -- sj >= cj
			bi=ci; bj=cj; ei=si; ej=sj
		end
		return bi, bj, ei, ej
	end
end

local function setcurj(j) -- set cursor on the current line
	local ci = getcur()
	local ln = #buf.ll[ci]
	if not j or j > ln then j = ln end
	buf.cj = j
	return j
end
		
local function setcur(i, j)
	if not i or i > #buf.ll then i = #buf.ll end
	if i < 1 then i = 1 end
	if not j or j > #buf.ll[i] then j = #buf.ll[i] end
	if j < 0 then j = 0 end
	buf.ci, buf.cj = i, j
	return i, j
end

local function addcur(di, dj) 
	buf.ci, buf.cj = buf.ci + di, buf.cj + dj
	return true
end

-- cursor movement -- return true, or nil/false if movement is not possible
local function curhome() buf.cj = 0; return true end
local function curend() setcur(buf.ci); return true end
local function curright() return not ateol() and addcur(0, 1) end
local function curleft() return not atbol() and addcur(0, -1) end
local function curup() return not atfirst() and addcur(-1, 0) end
local function curdown() return not atlast() and addcur(1, 0) end
local function curbot() return not atbot() and setcur(1, 0) end
local function cureot() return not ateot() and setcur() end

-- modification at cursor line

local function getline(i)
	-- return current line and cursor position in line
	-- if i is provided, return line i
	if i then return buf.ll[i], 1 end
	return buf.ll[buf.ci], buf.cj
end

local function setline(s)
	buf.ll[buf.ci] = s
	buf.chgd = true
end

local function insline(s)
	-- insert a line above current line
	-- if at end of text, append the line.
	if ateot() then table.insert(buf.ll, s) -- append
	else table.insert(buf.ll, buf.ci, s) -- insert
	end
	buf.chgd = true
end

local function remnextline()
	-- remove and return next line
	-- return nil if already on the last line
	if atlast() then return end
	local i = buf.ci + 1
	local l = buf.ll[i]
	table.remove(buf.ll, i)
	buf.chgd = true
	return l
end

------------------------------------------------------------------------
-- editor actions

local function anop()
	-- do nothing. cancel selection if any
	buf.si, buf.sj = nil, nil
	buf.chgd = true
end 

local function aright()
	return curright() or curdown() and curhome()
end
	
local function aleft()
	-- adjust eol (cj may be > eol when moving up/down)
	if ateol() then curend() end 
	return curleft() or (curup() and curend())
end

local function apgdn() for i = 1, buf.box.l - 2 do curdown() end end
local function apgup() for i = 1, buf.box.l - 2 do curup() end end

local function anl()
	local l, cj = getline()
	insline(l:sub(1, cj)); curdown()
	setline(l:sub(cj + 1)); curhome()
	return true
end

local function adel()
	local l, cj = getline()
	if ateot() then return false end
	if ateol() then
		setline(l .. remnextline())
	else
		setline(l:sub(1,cj) .. l:sub(cj+2))
	end
	return true
end

local function abksp()
	return aleft() and adel()
end

local function ainsch(k)
	local l, cj = getline()
	setline(l:sub(1, cj) .. char(k) .. l:sub(cj+1))
	curright()
end

local function aopenfile()
	local fn = readstr("open file: ")
	if not fn then msg""; return end
	local ll, errmsg = readfile(fn)
	if not ll then msg(errmsg); return end
	-- for the moment, forget about the current buffer... :-)
	buf = bufnew(ll) 
	buf.actions = editor.edit_actions
	fullredisplay()
end

local function actrlx()
	local k = editor.nextk()
	local bname = '^X-' .. term.keyname(k)
	msg(bname)
	local act = editor.ctrlx_actions[k]
	if act then 
		act() 
	else
		msg(bname .. " not bound")
	end
end--actrlx

local function asearchagain()
	repeat
		local l, cj = getline()
		local j = l:find(editor.pat, cj+2)
		if j then 
			setcurj(j-1)
			msg("found!")
			return true
		end
	until not curdown()
	msg("not found")
	popcur()
end

local function asearch()
	editor.pat = readstr("Search: ")
	return asearchagain()
end

local function amark()
	buf.si, buf.sj = buf.ci, buf.cj
	msg("Mark set.")
	buf.chgd = true
end

local function exch_mark()
	if buf.si then
		buf.si, buf.ci = buf.ci, buf.si
		buf.sj, buf.cj = buf.cj, buf.sj
	end
end

local function wipe()
	if not buf.si then msg("No selection."); return end
	editor.kll = {}
	-- make sure cursor is at beg of selection
	if markbeforecur() then exch_mark() end 
	local ci, cj = getcur()
	local si, sj = getsel()
	local l1, l2 = getline(), getline(si)
	setline(l1:sub(1, cj) .. l2:sub(sj+1))
	if ci == si then
		editor.kll[1] = l1:sub(cj+1, sj)
		goto done
	end
	editor.kll[1] = l1:sub(cj+1)
	for i = ci+1, si do 
		local l3 = remnextline() 
		if i < si then 	
			table.insert(editor.kll, l3)
		else -- last sel line
			table.insert(editor.kll, l3:sub(1, sj))
		end
	end
	::done::
	buf.si = nil
	buf.chgd = true
end--wipe

local function kill() 
	-- wipe from cursor to end of line
	-- del nl but do not modify the kill buffer if at eol
	if ateol() then return adel() end
	local l, cj = getline()
	editor.kll = { l:sub(cj+1) }
	return setline(l:sub(1, cj))
end--kill
	

local function yank()
	if not editor.kll or #editor.kll == 0 then 
		msg("nothing to yank!"); return end
	local l = getline()
	local ci, cj = getcur()
	local l1, l2 = l:sub(1, cj), l:sub(cj+1)
	if #editor.kll == 1 then 
		setline(l1 .. editor.kll[1] .. l2)
		setcur(ci, cj + #editor.kll[1])
		return
	end
	local kln = #editor.kll
	setline(l1 .. editor.kll[1])
	for i = 2, kln-1  do
		curend(); anl(); setline(editor.kll[i])
	end
	curend(); anl(); setline(editor.kll[kln] .. l2)
	ci, cj = getcur(); setcur(ci, #editor.kll[kln])
	buf.chgd = true
end--yank

local function aesc()
	local k = editor.nextk()
	local bname = 'ESC-' .. term.keyname(k)
	msg(bname)
	local act = editor.esc_actions[k]
	if act then 
		act() 
	else
		msg(bname .. " not bound")
	end
end--aesc

local function atest()
--~ 	s = readstr("enter a string: ")
--~ 	if not s then msg"NIL!" ; return end
--~ 	msg("the string is: '"..s.."'")
	buf.ll = editor.kll
	setcur(1, 0)
	buf.chgd = true
end--atest


------------------------------------------------------------------------
-- bindings

editor.edit_actions = { -- actions binding for text edition
	[0] = amark,   -- ^@
	[1] = curhome,   -- ^A
	[2] = aleft,   -- ^B
	[4] = adel,    -- ^D
	[5] = curend,    -- ^E
	[6] = aright,  -- ^F
	[7] = anop,    -- ^G (do nothing)
	[8] = abksp,   -- ^H
	[11] = kill,   -- ^k
	[12] = function() fullredisplay() end, -- ^L
	[13] = anl,    -- ^M (insert newline)
	[14] = curdown,  -- ^N
	[15] = aopenfile,  -- ^O
	[16] = curup,    -- ^P
	[17] = function() editor.quit = true end, -- ^Q
	[18] = asearchagain,  -- ^R
	[19] = asearch,  -- ^S
	[20] = atest,  -- ^T
	[23] = wipe,   -- ^W
	[24] = actrlx, -- ^X
	[25] = yank,   -- ^Y
	[27] = aesc,   -- ESC
	
	--
	[keys.kpgup] = apgup,
	[keys.kpgdn] = apgdn,
	[keys.khome] = curhome,
	[keys.kend] = curend,
	[keys.kdel] = adel, 
	[keys.del] = abksp, 
	[keys.kright] = aright,
	[keys.kleft] = aleft,
	[keys.kup] = curup,
	[keys.kdown] = curdown,

}--edit_actions

editor.ctrlx_actions = {
	[7] = anop,    -- ^G (do nothing - cancel ^X prefix)
	[24] = exch_mark,  -- ^X^X
}--ctrlx_actions

editor.esc_actions = {
	[7] = anop,     -- esc^G (do nothing - cancel ^X prefix)
	[60] = curbot,  -- esc <
	[62] = cureot,  -- esc >
}--esc_actions


function editor_loop()
	tl = he.fgetlines'zztest' -- [testfile. no file open for the moment]
	style.normal()
	buf = bufnew(tl)
	buf.actions = editor.edit_actions
	--
--~ 	buf.si, buf.sj = 6, 3
	--
	fullredisplay()
	while not editor.quit do
		local k = editor.nextk()
--~ 		if k == 17 then break end -- ^Q quits
		msg(term.keyname(k))
		local act = buf.actions[k]
		if act then 
			act()
		elseif (k >= 32 and k < 127) 
			or (k >= 160 and k < 256) 
			or (k == 9) then
			ainsch(k)
		else
			msg(term.keyname(k) .. " not bound")
		end
	redisplay(buf)
	end--while true
end

function main()
	-- set term in raw mode
	local prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	term.reset()
	-- run the application in a protected call so we can properly reset
	-- the tty mode and display a traceback in case of error
	local ok, msg = xpcall(editor_loop, debug.traceback)
	-- restore terminal in a a clean state
	term.show() -- show cursor
	term.left(999); term.down(999)
	style.normal()
	flush()
	--~ 	ln.setmode(omode)
	term.restoremode(prevmode)
	if not ok then -- display traceback in case of error
		print(msg)
		os.exit(1)
	end
--~ 	pp(editor.kll)
end

main()

