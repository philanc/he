-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[  ple - a Pure Lua Editor  		!!! WORK IN PROGRESS !!!



License: MIT

https://github.com/philanc/ple

]]

-- some local definitions (used by the module term and/or by the editor

local strf = string.format
local byte, char, rep = string.byte, string.char, string.rep
local app, concat = table.insert, table.concat
local yield = coroutine.yield

local repr = function(x) return strf("%q", tostring(x)) end
local function max(x, y) if x < y then return y else return x end end 
local function min(x, y) if x < y then return x else return y end end 

local function pad(s, w) -- pad a string to fit width w
	if #s >= w then return s:sub(1,w) else return s .. rep(' ', w-#s) end
end

local function readfile(fn)
	-- read file with filename 'fn' as a list of lines
	fh, errm = io.open(fn)
	if not fh then return nil, errm end
	local ll = {}
	for l in fh:lines() do table.insert(ll, l) end
	fh:close()
	return ll
end

------------------------------------------------------------------------
-- TERM MODULE

--[[

terminal utility module - unix only

(also available as a distinct module. see https://github.com/philanc/plterm )

This module assumes the tty is in raw mode. 
It provides functions based on stty (so available on unix) 
to save, set and restore tty modes.

-- just in case, a good ref on ANSI esc sequences:   
https://en.wikipedia.org/wiki/ANSI_escape_code
(in the text, "CSI" is "<esc>[")

]]


------------------------------------------------------------------------

local out = io.write

local function outf(...) 
	-- write arguments to stdout, then flush.
	io.write(...); io.flush()
end

local function outdbg(x, sep) 
	out(repr(x):sub(2, -2))
	if sep then out(sep) end
	io.flush() 
end

-- following definitions (from term.clear to term.restore) are
-- based on public domain code by Luiz Henrique de Figueiredo 
-- http://lua-users.org/lists/lua-l/2009-12/msg00942.html
term={
	out = out,
	outf = outf,
	outdbg = outdbg,
	clear = function() out("\027[2J") end,
	cleareol = function() out("\027[K") end,
	golc = function(l,c) out("\027[",l,";",c,"H") end,
	up = function(n) out("\027[",n or 1,";","A") end,
	down = function(n) out("\027[",n or 1,";","B") end,
	right = function(n) out("\027[",n or 1,";","C") end,
	left = function(n) out("\027[",n or 1,";","D") end,
	color = function(f,b,m) 
	    if m then out("\027[",f,";",b,";",m,"m")
	    elseif b then out("\027[",f,";",b,"m")
	    else out("\027[",f,"m") end 
	end,
	-- hide / show cursor
	hide = function() out("\027[?25l") end,
	show = function() out("\027[?25h") end,
	-- save/restore cursor position
	save = function() out("\027[s") end,
	restore = function() out("\027[u") end,
	-- reset terminal (clear and reset default colors)
	reset = function() out("\027c") end,
}

term.colors = {
	default = 0,
	-- foreground colors
	black = 30, red = 31, green = 32, yellow = 33, 
	blue = 34, magenta = 35, cyan = 36, white = 37,
	-- backgroud colors
	bgblack = 40, bgred = 41, bggreen = 42, bgyellow = 43,
	bgblue = 44, bgmagenta = 45, bgcyan = 46, bgwhite = 47,
	-- attributes
	reset = 0, normal= 0, bright= 1, bold = 1, reverse = 7,
}

------------------------------------------------------------------------
-- key input

term.keys = { -- key code definitions
	unknown = 0x10000,
	esc = 0x1b,
	del = 0x7f,
	kf1 = 0xffff,  -- 0xffff-0
	kf2 = 0xfffe,  -- 0xffff-1
	kf3 = 0xfffd,  -- ...
	kf4 = 0xfffc,
	kf5 = 0xfffb,
	kf6 = 0xfffa,
	kf7 = 0xfff9,
	kf8 = 0xfff8,
	kf9 = 0xfff7,
	kf10 = 0xfff6,
	kf11 = 0xfff5,
	kf12 = 0xfff4,
	kins  = 0xfff3,
	kdel  = 0xfff2,
	khome = 0xfff1,
	kend  = 0xfff0,
	kpgup = 0xffef,
	kpgdn = 0xffee,
	kup   = 0xffed,
	kdown = 0xffec,
	kleft = 0xffeb,
	kright = 0xffea,
}

local keys = term.keys

--special chars (for parsing esc sequences)
local ESC, LETO, LBR, TIL= 27, 79, 91, 126  --  esc, [, ~

local isdigitsc = function(c) 
	-- return true if c is the code of a digit or ';'
	return (c >= 48 and c < 58) or c == 59
end

--ansi sequence lookup table
local seq = {
	['[A'] = keys.kup,
	['[B'] = keys.kdown,
	['[C'] = keys.kright,
	['[D'] = keys.kleft,

	['[2~'] = keys.kins,
	['[3~'] = keys.kdel,
	['[5~'] = keys.kpgup,
	['[6~'] = keys.kpgdn,
	['[7~'] = keys.khome,  --rxvt
	['[8~'] = keys.kend,   --rxvt
	['[1~'] = keys.khome,  --linux
	['[4~'] = keys.kend,   --linux
	['[11~'] = keys.kf1,
	['[12~'] = keys.kf2,
	['[13~'] = keys.kf3,
	['[14~'] = keys.kf4,
	['[15~'] = keys.kf5,
	['[17~'] = keys.kf6,
	['[18~'] = keys.kf7,
	['[19~'] = keys.kf8,
	['[20~'] = keys.kf9,
	['[21~'] = keys.kf10,
	['[23~'] = keys.kf11,
	['[24~'] = keys.kf12,

	['OP'] = keys.kf1,   --xterm
	['OQ'] = keys.kf2,   --xterm
	['OR'] = keys.kf3,   --xterm
	['OS'] = keys.kf4,   --xterm
	['[H'] = keys.khome, --xterm
	['[F'] = keys.kend,  --xterm

	['[[A'] = keys.kf1,  --linux
	['[[B'] = keys.kf2,  --linux
	['[[C'] = keys.kf3,  --linux
	['[[D'] = keys.kf4,  --linux
	['[[E'] = keys.kf5,  --linux

}

local getcode = function() return byte(io.read(1)) end

term.input = function()
	-- return a "read next key" function that can be used in a loop
	-- the "next" function blocks until a key is read
	-- it returns ascii code for all regular keys, or a key code
	-- for special keys (see term.keys)
	-- (this function assume the tty is already in raw mode)
	return coroutine.wrap(function()
		local c, c1, c2, ci, s
		while true do
			c = getcode()
			if c ~= ESC then -- not a seq, yield c
				yield(c) 
				goto continue
			end 
			c1 = getcode()
			if c1 == ESC then -- esc esc [ ... sequence
				yield(ESC)
				-- here c still contains ESC, read a new c1
				c1 = getcode() -- and carry on ...
			end
			if c1 ~= LBR and c1 ~= LETO then -- not a valid seq
				yield(c) ; yield(c1)
				goto continue
			end
			c2 = getcode()
			s = char(c1, c2)
			if c2 == LBR then -- esc[[x sequences (F1-F5 in linux console)
				s = s .. char(getcode())
			end
			if seq[s] then 
				yield(seq[s])
				goto continue
			end
			if not isdigitsc(c2) then
				yield(c) ; yield(c1) ; yield(c2)
				goto continue
			end
			while true do
				ci = getcode()
				s = s .. char(ci)
				if ci == TIL then 
					if seq[s] then
						yield(seq[s])
						goto continue
					else
						-- valid but unknown sequence - ignore it
						yield(keys.unknown)
						goto continue
					end
				end
				if not isdigitsc(ci) then
					-- not a valid seq. return all the chars
					yield(ESC)
					for i = 1, #s do yield(byte(s, i)) end
					goto continue
				end
			end--while
			-- assume c is a regular char, return its ascii code
			::continue::
		end
	end)--coroutine
end--input()

term.rawinput = function()
	-- return a "read next key" function that can be used in a loop
	-- the "next" function blocks until a key is read
	-- it returns ascii code for all keys
	-- (this function assume the tty is already in raw mode)
	return coroutine.wrap(function()
		local c
		while true do
			c = getcode()
			yield(c) 
		end
	end)--coroutine
end--rawinput()

term.getcurpos = function()
	-- return current cursor position (line, coloumn as integers)
	--
	outf("\027[6n") -- report cursor position. answer: esc[n;mR
	local c, i = 0, 0
	local s = ""
	c = getcode(); if c ~= ESC then return nil end
	c = getcode(); if c ~= LBR then return nil end
	while true do
		i = i + 1
		if i > 8 then return nil end
		c = getcode()
		if c == byte'R' then break end
		s = s .. char(c)
	end
	-- here s should be n;m
	local n, m = s:match("(%d+);(%d+)")
	if not n then return nil end
	return tonumber(n), tonumber(m)
end

term.getscrlc = function()
	-- return current screen dimensions (line, coloumn as integers)
	term.save()
	term.down(999); term.right(999)
	local l, c = term.getcurpos()
	term.restore()
	return l, c
end

term.keyname = function(c)
	for k, v in pairs(keys) do 
		if c == v then return k end
	end
	if c < 32 then return "^" .. char(c+64) end
	if c < 256 then return char(c) end
	return tostring(c)
end

------------------------------------------------------------------------
-- poor man's tty mode management, based on stty
-- (better use slua linenoise extension if available)


-- use the following to define a non standard stty location
-- eg.:  stty = "/opt/busybox/bin/stty"
-- 
local stty = "stty" -- use the default stty

term.setrawmode = function()
	return os.execute(stty .. " raw -echo 2> /dev/null")
end

term.setsanemode = function()
	return os.execute(stty .. " sane")
end

term.savemode = function()
	local fh = io.popen(stty .. " -g")
	local mode = fh:read('a')
	print(mode)
	local succ, e, msg = fh:close()
	return succ and mode or nil, e, msg
end

term.restoremode = function(mode)
	return os.execute(stty .. " " .. mode)
end

-- return term -- END OF TERM MODULE


------------------------------------------------------------------------
-- EDITOR


-- some local definitions

-- the following is defined at the beginning of module term, above.
-- local out, outf, outdbg = term.out, term.outf, term.outdbg

local go, cleareol, color = term.golc, term.cleareol, term.color
local col, keys = term.colors, term.keys
local flush = io.flush

	
------------------------------------------------------------------------
-- global objects and constants

local tabln = 4
local EOL = char(187) -- >>, indicate more undisplayed chars in s
local NDC = char(183) -- middledot, used for non-displayable latin1 chars
local EOT = '~'  -- used to indicate that we are past the end of text

-- editor is the global editor object
local editor = {
	quit = false, -- set to true to quit editor_loop()
	nextk = term.input(), -- the "read next key" function
	buflist = {},  -- list of buffers
	bufindex = 0,  -- index of current buffer
}

-- buf is the current buffer
-- this is the same object as editor.buflist[editor.bufindex]
local buf = {}  

local function bufnew(ll)
	-- create and initialize a new buffer object
	-- ll is a list of lines
	local buf = { 
		ll=ll,        -- list of text lines
		ci=1, cj=0,   -- text cursor (line ci, offset cj)
		li=1,         -- index in ll of the line at the top of the box
		hs=0,         -- horizontal scroll (number of columns)
		chgd=true,    -- true if buffer has changed since last display
		unsaved=false,-- true if buffer content has changed since last save
		ual = {},     -- undo action list
		-- box: a rectangular region of the screen where the buffer 
		--      is displayed (see boxnew() below)
		--      the box is assigned to the buffer by a layout function.
		--      for the moment, the layout is performed by the 
		--      fullredisplay() function.
	}
	return buf
end

-- style functions

local style = {
	normal = function() color(col.normal) end, 
	status = function() color(col.red, col.bold) end, 
	msg = function() color(col.normal); color(col.green) end, 
	sel = function() color(col.magenta, col.bold) end, 
	bckg = function() color(col.black, col.bgyellow) end, 
}


-- dialog functions

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

local function readchar(prompt, charpat)
	-- display prompt on the last screen line, read a char
	-- if ^G then return nil
	-- return the key as a char only if it matches charpat
	-- ignore all non printable ascii keys and non matching chars
	msg(prompt)
	editor.redisplay(buf) -- ensure cursor stays in buf
	while true do
		k = editor.nextk()
		if k == 7 then return nil end -- ^G - abort
		if (k < 127) then
			local ch = char(k)
			if ch:match(charpat) then return ch end
		end
		-- ignore all other keys
	end--while
end --readkey

local function status(m)
	-- display a status string on top screen line
	m = pad(m, editor.scrc)
	go(1, 1); cleareol(); style.status()
	out(m); style.normal(); flush()
end

local dbgs = "::"
local function dbg(s, ...)
	dbgs = strf(s, ...)
end
	

local function statusline()
	local s = strf("cur=%d,%d ", buf.ci, buf.cj)
	if buf.si then s = s .. strf("sel=%d,%d ", buf.si, buf.sj) end
	-- uncomment the following for debug purposes
--~ 	s = s .. strf("li=%d ", buf.li)
--~ 	s = s .. strf("hs=%d ", buf.hs)
--~ 	s = s .. strf("ual=%d ", #buf.ual)
	s = s .. strf("buf=%d ", editor.bufindex)
	s = s .. strf("[%s] ", buf.filename or "unnamed")
	s = s .. strf("(%s) ", buf.unsaved and "*" or "")
--~ 	s = s .. strf("-- Help: ^X^H ", #buf.ual)
	s = s .. dbgs
	return s
end--statusline



------------------------------------------------------------------------
-- screen display functions  (boxes, line display)

local function boxnew(x, y, l, c)
	-- a box is a rectangular area on the screen
	-- defined by top left corner (x, y) 
	-- and number of lines and columns (l, c)
	local b = {x=x, y=y, l=l, c=c}
	b.clrl = rep(" ", c) -- used to clear box content
	return b
end

local function boxfill(b, ch, stylefn)
	local filler = rep(ch, b.c)
	stylefn()
	for i = 1, b.l do
		go(b.x+i-1, b.y); out(filler)
	end
	style.normal() -- back to normal style
	flush()
end

-- line display

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

local function boxline(b, hs, bl, l, insel, jon, joff)
	-- display line l at the bl-th line of box b, with horizontal scroll hs
	-- if s is tool long for the box, return the
	-- index of the first undisplayed char in l
	-- insel: true if line start is in the selection
	-- jon: if defined and not insel, position of beg of selection
	-- joff: if defined, position of end of selection
	local bc = b.c
	local cc = 0 --curent col in box
	-- clear line (don't use cleareol - box maybe smaller than screen)
	go(b.x+bl-1, b.y); out(b.clrl)  
	go(b.x+bl-1, b.y)
	if insel then style.sel() end
	for j = 1, #l do
		if (not insel) and j == jon+1 then style.sel(); insel=true end
		if insel and j == joff+1 then style.normal() end
		local chs = ccrepr(byte(l, j), cc)
		cc = cc + #chs
		if cc >= bc + hs then 
			go(b.x+bl-1, b.y+b.c-1)
			outf(EOL)
			style.normal()
			return j -- index of first undisplayed char in s
		end
		if cc > hs then out(chs) end
	end
	style.normal()
end --boxline

------------------------------------------------------------------------
-- screen redisplay functions


local function adjcursor(buf)
	-- adjust the screen cursor so that it matches with 
	-- the buffer cursor (buf.ci, buf.cj)
	--
	-- first, adjust buf.li
	local bl = buf.box.l
	if buf.ci < buf.li or buf.ci >= buf.li+bl then 
		-- cursor has moved out of box.
		-- set li so that ci is in the middle of the box
		buf.li = max(1, buf.ci-bl//2) 
		buf.chgd = true
	end
	local cx = buf.ci - buf.li + 1
	local cy = 1 -- box column index, ignoring horizontal scroll
	local col = buf.box.c
	local l = buf.ll[buf.ci]
	for j = 1, buf.cj do
		local b = byte(l, j)
		if not b then break end
		if b == 9 then cy = cy + (tabln - (cy-1) % tabln)
		else cy = cy + 1 
		end
--~ 		if cy > col then --don't move beyond the right of the box
--~ 			cy = col
--~ 			buf.cj = j
--~ 			break
--~ 		end
	end
	-- determine actual hs
	local hs = 0 -- horizontal scroll
	local cys = cy -- actual box column index
	while true do
		if cys >= col then 
			cys = cys - 40
			hs = hs + 40
		else
			break
		end
	end--while
	if hs ~= buf.hs then
		buf.chgd = true
		buf.hs = hs
	end
	if buf.chgd then return end -- (li or hs or content change)
	-- here, assume that cursor will move within the box
	status(statusline()) 
	go(buf.box.x + cx - 1, buf.box.y + cys - 1); flush()
end -- adjcursor


local function displaylines(buf)
	-- display buffer lines starting at index buf.li 
	-- in list of lines buf.ll
	local b, ll, li, hs = buf.box, buf.ll, buf.li, buf.hs
	local ci, cj, si, sj = buf.ci, buf.cj, buf.si, buf.sj
	local bi, bj, ei, ej -- beginning and end of selection
	local sel, insel, jon, joff = false, false, -1, -1
	if si then -- set beginning and end of selection
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
		boxline(b, hs, i, l, insel, jon, joff)
	end
	flush()
end

local function redisplay(buf)
	-- adjust cursor and repaint buffer lines if needed
	adjcursor(buf)
	if buf.chgd or buf.si then
		displaylines(buf)
		buf.chgd = false
		adjcursor(buf)
	end
	buf.chgd = false
end --redisplay


local function fullredisplay()
	-- complete repaint of the screen
	-- performed initially, or when a new buffer is displayed, or
	-- when requested by the user (^L command) because the 
	-- screen is garbled or the screensize has changed (xterm, ...)
	--
	editor.scrl, editor.scrc = term.getscrlc()
	-- [TMP!! editor.scrbox is a bckgnd box with a pattern to
	-- visually check that edition does not overflow buf box
	-- (this is for future multiple windows, including side by side)]
	editor.scrbox = boxnew(1, 1, editor.scrl, editor.scrc)
	boxfill(editor.scrbox, ' ', style.normal)
--~ 	buf.box = boxnew(2, 2, editor.scrl-3, editor.scrc-2)
--~ 	buf.box = boxnew(2, 1, editor.scrl-3, editor.scrc)
	buf.box = boxnew(2, 1, editor.scrl-2, editor.scrc)
	buf.chgd = true
	redisplay(buf)
end --fullredisplay

editor.redisplay = redisplay
editor.fullredisplay = fullredisplay

------------------------------------------------------------------------
-- BUFFER AND CURSOR MANIPULATION 
--
-- 		use these functions instead of direct buf.ll manipulation. 
-- 		This will make it easier to change or enrich the 
-- 		representation later. (eg. syntax coloring, undo/redo, ...)

-- various predicates and accessors

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

local function geteol() 
	-- return coord of current end of line
	local ci = buf.ci
	return ci, #buf.ll[ci]
end

local function getline(i)
	-- return current line and cursor position in line
	-- if i is provided, return line i
	if i then return buf.ll[i], 1 end
	return buf.ll[buf.ci], buf.cj
end

local function getlines(di, dj)
	-- return the text between the cursor and point (di, dj) as
	-- a list of lines. this assumes that (di, dj) is after the cursor.
	-- if cursor and point are on the same line, return only a string
	local ci, cj = getcur()
	if di == ci then
		return buf.ll[ci]:sub(cj+1, dj)
	end
	local sl = {}
	for i = ci, di do
		local l = buf.ll[i]
		if i == ci then l = l:sub(cj+1) end
		if i == di then l = l:sub(1, dj) end
		table.insert(sl, l)
	end
	return sl
end--getlines


-- cursor movement

local function setcurj(j) -- set cursor on the current line
	local ci = getcur()
	local ln = #buf.ll[ci]
	if not j or j > ln then j = ln end
	buf.cj = j
	return j
end
		
local function setcur(i, j) -- set cursor absolute
	if not i or i > #buf.ll then i = #buf.ll end
	if i < 1 then i = 1 end
	if not j or j > #buf.ll[i] then j = #buf.ll[i] end
	if j < 0 then j = 0 end
	buf.ci, buf.cj = i, j
	return i, j
end

local function addcur(di, dj) -- move cursor relative
	buf.ci, buf.cj = buf.ci + di, buf.cj + dj
	return true
end

-- buffer cursor movement 
-- return true, or nil/false if movement is not possible
local function curhome() buf.cj = 0; return true end
local function curend() setcur(buf.ci); return true end
local function curright() return not ateol() and addcur(0, 1) end
local function curleft() return not atbol() and addcur(0, -1) end
local function curup() return not atfirst() and addcur(-1, 0) end
local function curdown() return not atlast() and addcur(1, 0) end
local function curbot() return not atbot() and setcur(1, 0) end
local function cureot() return not ateot() and setcur() end

-- modification at cursor
-- all modifications should be performed by the following functions:
--	  bufins(strlist)
--		insert list of string at cursor. if strlist is a string, it is
--      equivalent to a list with only one element 
--		if buffer contains one line "abc" and cursor is between b and c
--		(ie screen cursor is on 'c') then 
--		bufins{"xx"}  changes the buffer line to "abxxc"
--		bufins{"xx", "yy"}  now the buffer has two lines: "abxx", "yyc"
--		bufins{"", ""}  inserts a newline:   "ab", "c"
--   bufdel(strlist)
--		delete a list of string at cursor. if strlist is a string, it is
--      equivalent to a list with only one element 
--		the list of string must match with the buffer content at the cursor
--		(it is passed to allow an undo)
--		if the buffer is  ("abxx", "yyc") and the cursor is just after 'b',
--		bufdel{"xx", "yy"} changes the buffer to ("abc")
--		at end of line, bufdel{"", ""} merges the line with the next line
--   bufdel(di, dj)
--		delete all characters between the cursor and point (di, dj)
--		(bufdel assumes that di, dj is after the cursor)
--		if the buffer is  ("abxx", "yyc") and the cursor is just after 'b',
--		bufdel(2,2) changes the buffer to ("abc")
--		

local ualpush -- defined further down with all undo functions

local function bufins(sl)
	ualpush('ins', sl)
	local ci, cj = getcur()
	local l = buf.ll[ci]
	local l1, l2 = l:sub(1,cj), l:sub(cj+1)
	local s1 = nil
	if type(sl) == "string" then	s1 = sl
	elseif #sl == 1 then  s1 = sl[1]
	end
	if s1 then -- insert s1 in current line
		buf.ll[ci] = l1 .. s1 .. l2
		setcur(ci, cj + #s1)
	else -- several lines in sl
		buf.ll[ci] = l1 .. sl[1]
		ci = ci + 1
		for i = 2, #sl-1 do
			table.insert(buf.ll, ci, sl[i])
			ci = ci + 1
		end
		local last = sl[#sl]
		cj = #last
		buf.ll[ci] = last .. l2
		setcur(ci, cj)
	end
	buf.chgd = true
	buf.unsaved = true
	return true
end--bufins

local function bufdel(di, dj)
	ualpush('del', getlines(di, dj))
	local ci, cj = getcur()
	local l1, l2 = buf.ll[ci]:sub(1,cj), buf.ll[di]:sub(dj+1)
	if di == ci then -- delete in current line at cursor
		buf.ll[ci] = l1 .. l2
	else -- delete several lines
		for i = ci+1, di do
			table.remove(buf.ll, i)
		end
		buf.ll[ci] = l1 .. l2
	end
	buf.chgd = true
	buf.unsaved = true
	return true
end--bufdel


------------------------------------------------------------------------
-- undo functions  !! NOT IMPLEMENTED YET !!

function ualpush(op, s)
	-- do nothing - no Undo yet!
end

--[[
function ualpush(op, s)
	-- push enough context to be able to undo a core operation
	-- (setline, openline, joinline)
	local top = #buf.ual
	local last = buf.ual[top]
	if last and last.op == "set" and op == "set" and buf.ci == last.ci then
		-- all sequential 'set' actions on the same line are 
		-- bundled together in the same record
		last.s = s
		return
	end
	local rec = {op=op, ci=buf.ci, cj=buf.cj}
	if op == "set" then
		rec.ol = getline()
		rec.l = s
	end
	table.insert(buf.ual, rec)
	return
end

]]


------------------------------------------------------------------------
-- EDITOR ACTIONS

editor.actions = {}
local e = editor.actions

function e.nop()
	-- do nothing. cancel selection if any
	buf.si, buf.sj = nil, nil
	buf.chgd = true
end 

e.redisplay = fullredisplay
e.gohome = curhome
e.goend = curend
e.goup = curup
e.godown = curdown
e.gobot = curbot
e.goeot = cureot

function e.goright()
	return curright() or curdown() and curhome()
end
	
function e.goleft()
	-- adjust eol (cj may be > eol when moving up/down)
	if ateol() then curend() end 
	return curleft() or (curup() and curend())
end

function e.pgdn() for i = 1, buf.box.l - 2 do curdown() end end
function e.pgup() for i = 1, buf.box.l - 2 do curup() end end

function e.nl()
	return bufins({"", ""})
end

function e.del()
	if ateot() then return false end
	local ci, cj = getcur()
	if ateol() then return bufdel(ci+1, 0) end
	return bufdel(ci, cj+1)
end

function e.bksp()
	return e.goleft() and e.del()
end

function e.insch(k)
	bufins(char(k))
end

function e.ctrlx()
	local k = editor.nextk()
	local bname = '^X-' .. term.keyname(k)
	msg(bname)
	local act = editor.ctrlx_actions[k]
	if act then 
		return act() 
	else
		msg(bname .. " not bound")
	end
end--actrlx

function e.searchagain(actfn)
	-- search editor.pat. If found, execute actfn
	-- default action is to display a message "found!")
	-- on success, return the result of actfn() or true.
	-- (note: search does NOT ignore case)
	if not editor.pat then 
		msg("no string to search")
		return nil
	end
	local oci, ocj = getcur() -- save the original cursor position
	while true do
		local l, cj = getline()
		local j = l:find(editor.pat, cj+2, true) --plain text search
		if j then --found
			setcurj(j-1)
			if actfn then 
				return actfn()
			else
				msg("found!")
				return true
			end
		end -- found
		if not (curdown() and curhome()) then
			break -- at end of file and not found yet
		end
	end--while
	msg("not found")
	setcur(oci, ocj) -- restore cursor position
end

function e.search()
	editor.pat = readstr("Search: ")
	if not editor.pat then 
		msg("aborted.")
		return
	end
	return e.searchagain()
end

function e.replaceagain()
	local replall = false -- true if user selected "replace (a)ll"
	local n = 0 -- number of replaced instances
	function replatcur()
		-- replace at cursor (called only when editor.pat is found
		-- at cursor)
		local l, cj = getline()
		-- don't use gsub (pat and patrepl are plain text, unescaped)
		local l1, l2 = l:sub(1, cj), l:sub(cj + #editor.pat + 1)
		setline(l1 .. editor.patrepl .. l2)
		setcurj(cj + #editor.patrepl)
		n = n + 1
		return true
	end--replatcur
	function replfn()
		-- this function is called each time editor.pat is found
		-- return true to continue, nil/false to stop
		if replall then 
			return replatcur()
		else
			local ch = readchar( -- ask what to do
				"replace? (q)uit (y)es (n)o (a)ll (^G) ", "[anqy]")
			if not ch then return nil end
			if ch == "a" then -- replace all
				replall = true
				return replatcur()
			elseif ch == "y" then -- replace
				return replatcur()
			elseif ch == "n" then -- continue
				return true
			else -- assume q (quit)
				return nil
			end
		end
	end--replfn
	while e.searchagain(replfn) do end
	msg(strf("replaced %d instance(s)", n))
end--replaceagain

function e.replace()
	editor.pat = readstr("Search: ")
	if not editor.pat then 
		msg("aborted.")
		return
	end
	editor.patrepl = readstr("Replace with: ")
	if not editor.patrepl then 
		msg("aborted.")
		return
	end
	return e.replaceagain()
end--replace

function e.kill() 
	-- wipe from cursor to end of line
	-- del nl but do not modify the kill buffer if at eol
	if ateol() then return e.del() end
	local di, dj = geteol()
	s = getlines(di, dj)
	editor.kll = (type(s) == "table") and s or { s }
	return bufdel(di, dj)
end--kill

function e.killeol(appflag)
	-- wipe from cursor to eol included. copy to the kill buffer
	-- or append to the kill buffer if last action was also 'killeol'
	-- if appflag is true, always append to the kill buffer (default: false)
	-- (be careful if modifying this. it is also used by e.wipe())
	if ateot() then return end
	local l, cj = getline()
	appflag = appflag or (editor.lastresult == e.killeol)
	if not appflag then -- start with a fresh kill buffer
		editor.kll = {}
	else
		-- here either kll is empty 
		-- or last item is an empty line => remove it
		table.remove(editor.kll)
	end
	table.insert(editor.kll, l:sub(cj+1))
	table.insert(editor.kll, "")
	setline(l:sub(1, cj))
	joinline()
	-- allow to detect that previous command was also killeol
	return e.killeol 
end--killeol

function e.mark()
	buf.si, buf.sj = buf.ci, buf.cj
	msg("Mark set.")
	buf.chgd = true
end

function e.exch_mark()
	if buf.si then
		buf.si, buf.ci = buf.ci, buf.si
		buf.sj, buf.cj = buf.cj, buf.sj
	end
end

function e.wipe()
	if not buf.si then msg("No selection."); return end
	editor.kll = {}
	-- make sure cursor is at beg of selection
	if markbeforecur() then e.exch_mark() end 
	e.exch_mark(); e.nl() -- open line at end of selection
	e.exch_mark() -- back to beginning of selection
	local ci, cj = getcur()
	local si, sj = getsel()
	for i = ci+1, si do e.killeol(true) end
	-- remove the nl added at end of selection from the kill buffer
	table.remove(editor.kll)
	buf.si = nil
end--wipe	

function e.yank()
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
		curend(); e.nl(); setline(editor.kll[i])
	end
	curend()
	e.nl()
	setline(editor.kll[kln] .. l2)
	ci, cj = getcur(); setcur(ci, #editor.kll[kln])
end--yank

function e.quiteditor()
	editor.quit = true
end

function e.exiteditor()
	local anyunsaved = false
	for i, bx in ipairs(editor.buflist) do 
		anyunsaved = anyunsaved or bx.unsaved
	end
	if anyunsaved then
		local ch = readchar("Some buffers not saved. Quit? ", "[YNQynq\r\n]")
		if ch ~= "y" and ch ~= "Y" then 
			msg("aborted.")
			return
		end
	end
	editor.quit = true
	msg("exiting.")
end

function e.esc()
	local k = editor.nextk()
	local bname = 'ESC-' .. term.keyname(k)
	msg(bname)
	local act = editor.esc_actions[k]
	if act then 
		return act() 
	else
		msg(bname .. " not bound")
	end
end--aesc

function e.newbuffer(ll, fname)
	fname = fname or "" -- default is no filename
	ll = ll or { "" } -- default is a buffer with one empty line
	local b = bufnew(ll) 
	b.actions = editor.edit_actions 
	b.filename = fname
	local bi = editor.bufindex + 1 -- insert just after the current buffer
	table.insert(editor.buflist, bi, b) 
	editor.bufindex = bi
	buf = b
	fullredisplay()
end

function e.nextbuffer()
	-- switch to next buffer
	local bln = #editor.buflist
	editor.bufindex = editor.bufindex % bln + 1
	buf = editor.buflist[editor.bufindex]
	fullredisplay()
end--nextbuffer

function e.prevbuffer()
	-- switch to previous buffer
	local bln = #editor.buflist
	-- if bufindex>1, the "previous" buffer index should be bufindex-1
	-- if bufindex==1, the "previous" buffer index should be bln
	editor.bufindex = (editor.bufindex - 2) % bln + 1
	buf = editor.buflist[editor.bufindex]
	fullredisplay()
end--nextbuffer

function e.findfile()
	local fn = readstr("Open file: ")
	if not fn then msg""; return end
	local ll, errmsg = readfile(fn)
	if not ll then msg(errmsg); return end
	e.newbuffer(ll)
	buf.filename = fn
--~ 	fullredisplay()
end--findfile

function e.writefile(fname)
	fname = fname or readstr("Write to file: ")
	if not fname then msg("Aborted."); return end
	fh, errmsg = io.open(fname, "w")
	if not fh then msg(errmsg); return end
	for i = 1, #buf.ll do fh:write(buf.ll[i], "\n") end
	fh:close()
	buf.filename = fname
	buf.unsaved = false
	msg(fname .. " saved.")
end--writefile

function e.savefile()
	e.writefile(buf.filename)
end--savefile

function e.help()
	for i, bx in ipairs(editor.buflist) do
		if bx.filename == "*HELP*" then
			buf = bx; editor.bufindex = i
			fullredisplay()
			return
		end
	end -- help buffer not found, then build it.
	local ll = {}
	for l in editor.helptext:gmatch("(.-)\n") do table.insert(ll, l) end
	return e.newbuffer(ll, "*HELP*")
end--help

function e.test()
--~ 	-- test readstr
--~ 	s = readstr("enter a string: ")
--~ 	if not s then msg"NIL!" ; return end
--~ 	msg("the string is: '"..s.."'")

	-- test kill
	buf.ll = editor.kll or {}
	setcur(1, 0)
	buf.chgd = true

--~ 	-- test readchar
--~ 	local ch = readchar("test readchar: ", "[abc]")
--~ 	if not ch then msg("aborted!")
--~ 	else msg("readchar => "..ch)
--~ 	end
end--atest

editor.helptext = [[

*HELP*			-- back to the previous buffer: ^X^P

Cursor movement
	Arrows, PageUp, PageDown, Home, End
	^A ^E		go to beginning, end of line
	^B ^F		go backward, forward
	^N ^P		go to next line, previous line
	esc-< esc-> go to beginning, end of buffer
	^S			forward search (plain text, case sensitive)
	^R			search again (string previously entered with ^S)
   
Edition
	^D, Delete	delete character at cursor
	^H, bcksp	delete previous character
	^K			cut from cursor to end of line
	esc-k       cut from cursor to beginning of next line
	^space, ^@	mark  (set beginning of selection)
	^W			wipe (cut selection)
	^Y			yank (paste)

Files, buffers
	^X^F		prompt for a filename, read the file in a new buffer
	^X^W		prompt for a filename, write the current buffer
	^X^S		save the current buffer
	^X^B		create a new, empty buffer
	^X^N		switch to the next buffer
	^X^P		switch to the previous buffer

Misc.
	^X^C		exit the editor
	^G			abort the current command
	^L			redisplay the screen (useful if the screen was garbled
				or its dimensions changed)
	F1, ^X^H	this help text

]]

------------------------------------------------------------------------
-- bindings

editor.edit_actions = { -- actions binding for text edition
	[0] = e.mark,          -- ^@
	[1] = e.gohome,        -- ^A
	[2] = e.goleft,        -- ^B
	[4] = e.del,           -- ^D
	[5] = e.goend,         -- ^E
	[6] = e.goright,       -- ^F
	[7] = e.nop,           -- ^G (do nothing)
	[8] = e.bksp,          -- ^H
	[11] = e.kill,         -- ^k
	[12] = e.redisplay,    -- ^L
	[13] = e.nl,           -- ^M (insert newline)
	[14] = e.godown,       -- ^N
	[16] = e.goup,         -- ^P
	[17] = e.quiteditor,   -- ^Q
	[18] = e.searchagain,  -- ^R
	[19] = e.search,       -- ^S
	[20] = e.test,         -- ^T
	[23] = e.wipe,         -- ^W
	[24] = e.ctrlx,        -- ^X
	[25] = e.yank,         -- ^Y
	[27] = e.esc,          -- ESC
	--
	[keys.kpgup]  = e.pgup,
	[keys.kpgdn]  = e.pgdn,
	[keys.khome]  = e.gohome,
	[keys.kend]   = e.goend,
	[keys.kdel]   = e.del, 
	[keys.del]    = e.bksp, 
	[keys.kright] = e.goright,
	[keys.kleft]  = e.goleft,
	[keys.kup]    = e.goup,
	[keys.kdown]  = e.godown,
	[keys.kf1]    = e.help,

}--edit_actions

editor.ctrlx_actions = {
	[2] = e.newbuffer,    -- ^X^B
	[3] = e.exiteditor,   -- ^X^C
	[6] = e.findfile,     -- ^X^F
	[7] = e.nop,          -- ^X^G (do nothing - cancel ^X prefix)
	[8] = e.help,         -- ^X^H
	[14] = e.nextbuffer,  -- ^X^N
	[16] = e.prevbuffer,  -- ^X^P
	[19] = e.savefile,    -- ^X^S
	[23] = e.writefile,   -- ^X^W
	[24] = e.exch_mark,   -- ^X^X
}--ctrlx_actions

editor.esc_actions = {
	[7] = e.nop,     -- esc^G (do nothing - cancel ESC prefix)
	[49] = e.help,   -- esc 1
	[53] = e.replace,  -- esc 5 -%
	[55] = e.replaceagain,  -- esc 7 -&
	[60] = e.gobot,  -- esc <
	[62] = e.goeot,  -- esc >
	[107] = e.killeol,  -- esc k
}--esc_actions

function editor_loop(ll, fname)
	style.normal()
	e.newbuffer(ll, fname); 
	msg("Help: F1 or ^X^H or esc-1")
	redisplay(buf) -- adjust cursor to beginning of buffer
	while not editor.quit do
		local k = editor.nextk()
--~ 		if k == 17 then break end -- ^Q quits
		msg(term.keyname(k))
		local act = buf.actions[k]
		if act then 
			editor.lastresult = act()
		elseif (k >= 32 and k < 127) 
			or (k >= 160 and k < 256) 
			or (k == 9) then
			editor.lastresult = e.insch(k)
		else
			msg(term.keyname(k) .. " not bound")
		end
	redisplay(buf)
	end--while true
end

function main()
	-- process argument
	local ll, fname 
	if arg[1] then
		ll, err = readfile(arg[1]) -- load file as a list of lines
		if not ll then print(err); os.exit(1) end
		fname = arg[1]
	end
	-- set term in raw mode
	local prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	term.reset()
	-- run the application in a protected call so we can properly reset
	-- the tty mode and display a traceback in case of error
	local ok, msg = xpcall(editor_loop, debug.traceback, ll, fname)
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

