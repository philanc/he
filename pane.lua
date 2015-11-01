-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[	pane.lua

terminal utility module (based on the ltbox library)


]]


------------------------------------------------------------------------
-- some local definitions

local lt = require 'ltbox'
local term = require 'term'

local colors, keys = term.colors, term.keys

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

------------------------------------------------------------------------

local pane = he.class()

function pane.init(p, x, y, w, h, attr, selattr)
	p.x, p.y, p.w, p.h = x, y, w, h
	p.attr = attr or 0
	p.selattr = selattr or 0
	p.content = p.content or {}
end

local theme = {
	scr = {		attr = colors.yellow,
				fill = 32
	},
	vsep = {	attr = colors.bgmagenta,
				fill = 124, --'|'
	},
	minisep = {	attr = colors.bggreen,
				fill = byte'-',
	},
	mini = {	attr = 0,
				selattr = colors.reverse,
				fill = 32,
	},
	left = {	attr = 0,
				selattr = colors.reverse,
				fill = 183,
	},
	right = {	attr = colors.red,
				selattr = colors.reverse,
				fill = 183,
	},
}

function defaultfill(b)
	-- fill box b with its default fill character
	term.putfiller(b, b.fill)
end

function displine1(b)
	term.putfiller(b, b.fill)
	term.putstring(b.line1, b.x, b.y, b.xm, b.attr)
end




function newscr(pnb)
	pnb = pnb or 1  -- default is to start with one pane (left)
	local scr = {}
	scr.pnb = pnb or 1
	-- define all boxes
	scr.boxnames = {'right', 'left', 'vsep', 'minisep', 'mini'} 
	for i, b in ipairs(scr.boxnames) do
		scr[b] = term.newbox(
			1, 1, 1, 1, -- dimensions will be set later (function resize)
			theme[b].attr, theme[b].selattr
		)
		scr[b].fill = theme[b].fill
		scr[b].show = true
		scr[b].display = defaultfill --default display function
	end
	-- adjust visibility if only one pane
	scr.right.show = (pnb == 2)
	scr.vsep.show = (pnb == 2)
	-- adjust mini display
	scr.mini.line1 = '(line1)'
	scr.mini.display = displine1
	return scr
end

function resize(scr)
	local w, h = scr.w, scr.h
	-- resize minibuffer
	local m, ms = scr.mini, scr.minisep
	m.x, m.y, m.xm, m.ym = 1, h-1, w, h
	ms.x, ms.y, ms.xm, ms.ym = 1, h-2, w, h-2
	-- resize panes
	local l, r, v = scr.left, scr.right, scr.vsep
	if r.show then
		-- resize left, right and vsep
		local w2 = w // 2
		l.x, l.y, l.xm, l.ym = 1, 1, w2-1, h-3
		r.x, r.y, r.xm, r.ym = w2+1, 1, w, h-3
		v.x, v.y, v.xm, v.ym = w2, 1, w2, h-3
	else
		-- resize only left
		l.x, l.y, l.xm, l.ym = 1, 1, w, h-3
	end
end
	
function redisplay(scr)
	for i, bn in ipairs(scr.boxnames) do
		scr[bn]:display()
		lt.present()
	end
	lt.present()

end

------------------------------------------------------------------------

function testinit(attr)
	attr = attr or 0
	lt.init()
	ws, hs = lt.screen_wh()
	lt.clear(attr)
end

function testdispwait()
	lt.present()
	evt = {}
	et = lt.pollevent(evt)
end


function test1()
	local evt = {}
	local et
	testinit()
	scr = newscr(2)
	scr.w, scr.h = lt.screen_wh()
	while true do
		resize(scr)
		redisplay(scr)
		redisplay(scr)
		et = lt.pollevent(evt)
		if et==1 and evt.ch == string.byte'q' then break end
		scr.mini.line1 = strf("et:%d  w:%d  h:%d", et, evt.w, evt.h)
		if et == 2 then
			scr.w, scr.h = evt.w, evt.h
		end
		
	end
	lt.shutdown() -- no return val	
	
end

ok, msg = pcall(test1)
if not ok then 
		lt.shutdown()
		print("!!! ERROR !!!")
		print(msg)
else
	print("screen w h", scr.w, scr.h)
	print("done.")
end

