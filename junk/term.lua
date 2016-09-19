-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[	term.lua

terminal utility module 

(require the slua linenoise binding)


good ref:   ("CSI" is "<esc>[")
https://en.wikipedia.org/wiki/ANSI_escape_code

]]


------------------------------------------------------------------------
-- some local definitions

local he = require 'he'

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

local yield = coroutine.yield

------------------------------------------------------------------------
-- following definitions (from output to restore) are
-- based on public domain code by Luiz Henrique de Figueiredo 
-- http://lua-users.org/lists/lua-l/2009-12/msg00942.html

local out = io.write

term={
	output = out,
	clear = function () out("\027[2J") end,
	cleareol = function () out("\027[K") end,
	golc = function (l,c) out("\027[",l,";",c,"H") end,
	up = function (n) out("\027[",n or 1,";","A") end,
	down = function (n) out("\027[",n or 1,";","B") end,
	right = function (n) out("\027[",n or 1,";","C") end,
	left = function (n) out("\027[",n or 1,";","D") end,
	color = function (f,b,m) 
	    if m then out("\027[",f,";",b,";",m,"m")
	    elseif b then out("\027[",f,";",b,"m")
	    else out("\027[",f,"m") end 
	end,
	-- save/restore cursor position
	save = function () out("\027[s") end,
	restore = function () out("\027[u") end,
	-- reset terminal (clear and reset default colors)
	reset = function () out("\027c") end,

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

term.keys = {
	unknown        = 0x10000,
	esc            = 0x1b,
	del            = 0x7f,
	kf1            = 0xffff,  -- 0xffff-0
	kf2            = 0xfffe,  -- 0xffff-1
	kf3            = 0xfffd,  -- ...
	kf4            = 0xfffc,
	kf5            = 0xfffb,
	kf6            = 0xfffa,
	kf7            = 0xfff9,
	kf8            = 0xfff8,
	kf9            = 0xfff7,
	kf10           = 0xfff6,
	kf11           = 0xfff5,
	kf12           = 0xfff4,
	kins           = 0xfff3,
	kdel           = 0xfff2,
	khome          = 0xfff1,
	kend           = 0xfff0,
	kpgup          = 0xffef,
	kpgdn          = 0xffee,
	kup            = 0xffed,
	kdown          = 0xffec,
	kleft          = 0xffeb,
	kright         = 0xffea,
	mouseleft      = 0xffe9,
	mouseright     = 0xffe8,
	mousemiddle    = 0xffe7,
	mouserelease   = 0xffe6,
	mousewheelup   = 0xffe5,
	mousewheeldown = 0xffe4,  -- 0xffff-27
	-- modifiers
	mod_alt        = 0x01,
}

term.scrsize = function()
	-- return screen dimensions (number of lines, number of columns
	local s, e = he.shell("stty size")
	if e == 0 then
		local l, c = s:match("(%d+)%s+(%d+)")
		return l, c
	else
		return nil, "term: stty size error"
	end
end

term.outdbg = function(x) 
	out(he.repr(x):sub(2, -2))
	io.flush() 
end

local function sleep(n) local j=0 ; for i=1,n*1000000 do j=j+1 end end
local outf = function(x) out(x) ; io.flush() end
local morekeys = function() sleep(1); return ln.kbhit() end
local getcode = function() return byte(io.read(1)) end
local keys = term.keys

--special chars
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

term.input = function()
	-- return a "read next key" function that can be used in a loop
	-- the "next" function blocks until a key is read
	-- it returns ascii code for all regular keys, or a key code
	-- for special keys (see term.keys)
	-- (this function assume the tty is already in raw mode)
	return coroutine.wrap(function()
		local c, c1, c2, c3, c4, ci, s
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
	term.save()
	term.down(999); term.right(999)
	local l, c = term.getcurpos()
	term.restore()
	return l, c
end

term.getkeyname = function(c)
	for k, v in pairs(keys) do 
		if c == v then return k end
	end
	if c < 32 then return "^" .. char(c+64) end
	if c < 256 then return char(c) end
	return tostring(c)
end
	
		
	
	
------------------------------------------------------------------------
--[[
he.interactive()
ln = require"linenoise"
--~ pp(ln)
if not ln.isatty(1) then exit(1) end
col = term.colors

term.color(col.white, col.bgblack)
term.color(col.normal)

--~ term.clear()
--~ term.golc(1,1)
--~ term.output(term.scrsize())
--~ term.golc(3, 20)
--~ term.color(col.white, col.bgred, col.reverse)
--~ term.color(col.reverse)
--~ term.color(col.red, col.bold)
--~ term.color(col.red)
--~ term.output(he.isodate(), "\t\t!!!")
--~ term.output("\r")
--~ term.output("XXZZ\n")
--~ term.color(col.white, col.bgblack, col.normal)
--~ term.color(col.normal)
--~ term.color(col.normal)
--~ term.reset()
--~ term.color(col.yellow, col.reverse)
--~ term.output(he.isodate())

local outr = term.outdbg
local outx = function(x) out(strf("%02X ", x)) ; io.flush() end
local outx = function(x) out(strf("%d ", x)) ; io.flush() end
local nextk = term.input()

--~ outx = function(x) outr(char(x)) end
--~ local nextk = term.rawinput()

local nextc = function() return string.char(nextk()) end
omode = ln.getmode()

-- request cursor position
print"cursor position (esc 6n) - press '.' to exit"
ln.setrawmode()

l, c = term.getscrlc()
term.color(col.red, col.bold)
io.write(l, ' ', c, ': '); io.flush()
term.color(col.normal)

--~ while not morekeys() do outf('='); sleep(1) end ; goto reset

--~ outf("\027[6n")
while true do
--~ 	local c = io.read(1)
	local k = nextk()
	if k == nil then outx(0x100000) ; break end
	if k == byte'.' then break end
--~ 	outf(he.repr(c))
	local name = term.getkeyname(k)
	if name then
		outf(name .. " ") 
	else 
		outx(k)
	end
end

::reset::
ln.setmode(omode)


-- ]]


------------------------------------------------------------------------
return term

