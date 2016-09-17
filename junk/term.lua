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
	escape         = 0x1b,
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
------------------------------------------------------------------------
--[[
he.interactive()
ln = require"linenoise"
pp(ln)
if not ln.isatty(1) then exit(1) end
col = term.colors

term.color(col.white, col.bgblack)
term.color(col.normal)

term.clear()
term.golc(1,1)
term.output(term.scrsize())
term.golc(3, 20)
--~ term.color(col.white, col.bgred, col.reverse)
--~ term.color(col.reverse)
--~ term.color(col.red, col.bold)
term.color(col.red)
term.output(he.isodate(), "\t\t!!!")
term.output("\r")
term.output("XXZZ\n")
--~ term.color(col.white, col.bgblack, col.normal)
--~ term.color(col.normal)
term.color(col.normal)
--~ term.reset()
--~ term.color(col.yellow, col.reverse)
--~ term.output(he.isodate())

-- ]]


------------------------------------------------------------------------
return term

