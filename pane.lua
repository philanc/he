-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[	pane.lua

(non usable)

]]


------------------------------------------------------------------------
-- some local definitions

local lt = require 'ltbox'
local term = require 'term'
local he = require 'he'

local colors, keys = term.colors, term.keys

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

------------------------------------------------------------------------

function center(s, w)
	-- center string s on width w
	if #s > w then return s:sub(1, w) end
	local w1 = (w - #s) // 2
	local w2 = w - #s - w1
	return (" "):rep(w1) .. s .. (" "):rep(w2)
end

local theme = {
	scr = {		attr = colors.yellow,
				fill = 32
	},
	top = {	    attr = colors.bgred,
				fill = byte'-',
	},
	vsep = {	attr = colors.bgmagenta,
				fill = 124, --pipe char
	},
	msep = {	attr = colors.bggreen,
				fill = byte'-',
	},
	mini = {	attr = 0,
				selattr = colors.reverse,
				fill = 32,
	},
	main = {	attr = 0,
				selattr = colors.reverse,
				fill = 183,
	},
	popup = {	attr = colors.bgyellow | colors.black,
				selattr = colors.reverse,
				fill = byte' ',
				frame = colors.bgyellow,
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

function paintline(b)
	term.putfiller(b, b.fill)
	term.putstring(b.content, b.x, b.y, b.xm, b.attr)
	b.changed = true
end

function paintlinelist(b)
	term.putfiller(b, b.fill)
	term.putlist(b, b.content, 1)
	b.changed = false
end

local function setcontent(b, content)
	content = content or b.content
	b.content = content
	b.changed = true
end
	

-- define panes
-- scr :: vlist(top, main, msep, mini)
-- left and right panes if any will be subboxes of main

local top = {
	attr = theme.top.attr,
	fill = theme.top.fill,
	show = true, 
	setcontent = setcontent,
	paint = paintline,
	resize = function(self, w, h)
		self.x, self.y, self.xm, self.ym = 1, 1, w, 1
		end,
}--top

local main = {
	attr = theme.main.attr,
	selattr = theme.main.selattr,
	fill = theme.main.fill,
	show = true, 
	setcontent = setcontent,
	paint = paintlinelist,
	resize = function(self, w, h)
		self.x, self.y, self.xm, self.ym = 1, 2, w, h-3
		end,
}--main

local msep = {
	attr = theme.msep.attr,
	fill = theme.msep.fill,
	show = true, 
	setcontent = setcontent,
	paint = paintline,
	resize = function(self, w, h)
		self.x, self.y, self.xm, self.ym = 1, h-2, w, h-2
		end,
}--msep

local mini = {
	attr = theme.mini.attr,
	selattr = theme.mini.selattr,
	fill = theme.mini.fill,
	show = true, 
	setcontent = setcontent,
	paint = paintline,
	resize = function(self, w, h)
		self.x, self.y, self.xm, self.ym = 1, h-1, w, h
		end,
}--mini

local popup = {
	attr = theme.popup.attr,
	selattr = theme.popup.selattr,
	fill = theme.popup.fill,
	show = false, 
	setcontent = setcontent,
	paint = function(self)
		local p = self
		term.putfiller{x=p.x-2, y=p.y-1, xm=p.xm+2, ym=p.ym+1, attr=p.attr}
		paintlinelist(self)
		end,
	ipw = 50, -- inner popup width (ie. usable width)
	iph = 5,  -- inner popup height (id.)
	resize = function(self, w, h)
		local ipw, iph = self.ipw, self.iph
		self.x, self.y = w//2-ipw//2, h//2-iph//2
		self.xm, self.ym = self.x+ipw, self.y+iph
		end,
}--popup


local scr = {
	top = top, 
	main = main,
	msep = msep,
	mini = mini,
	popup = popup,
	boxnames = {'top', 'main', 'msep', 'mini', 'popup'},
	w = 80,
	h = 24,
	quit = false,
}

-- add a reference to scr in each pane
for i, bn in ipairs(scr.boxnames) do scr[bn].scr = scr end

scr.resize = function(scr)
	for i, bn in ipairs(scr.boxnames) do 
		scr[bn]:resize(scr.w, scr.h)
	end
end --resize

scr.display = function(scr, force)
	for i, bn in ipairs(scr.boxnames) do
		if scr[bn].show and (scr[bn].changed or force) then
			scr[bn]:paint()
			scr[bn].changed = false
			lt.present()
		end
	end
end --display

scr.init = function(scr)
	scr.w, scr.h = lt.screen_wh()
	-- define sizes of all boxes
	top:setcontent("(top)")
	msep:setcontent("(msep)")
	mini:setcontent("(mini)")
	main:setcontent{"main"}
	popup:setcontent{"POPUP!"}
	scr:resize()
	-- initial display
	scr:display(true)
end

------------------------------------------------------------------------

function setline(b, s)
	b.line = s
	b.changed = true
	b.scr:display()
end

function mini.info(mini, s)
	mini:setcontent(s)
	mini.scr:display()
end

function mini.msg(mini, s)
	local ch
	local evt = {}
	mini:setcontent(s .. " [ok]")
	mini.scr:display()
	repeat ch = inputstep(mini.scr, evt) until ch==13 or ch==27
	mini:info("")
end

function popup.alert(popup, s)
	local evt = {}
	local sl = (type(s) == "table") and s or he.lines(tostring(s))
	popup:setcontent(sl)
	popup.show = true
	popup.scr:display()
	repeat ch = inputstep(mini.scr, evt) until ch==13 or ch==27
	popup.show = false
	popup:setcontent{}
	popup.scr:display(true)
end

local function settext(b, txt)
	b:setcontent(he.lines(txt))
end

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

function setevtstatus(scr, et, ch, key, w, h)
	setcontent(top, strf("et:%d  ch:%d  key:%d  w:%d  h:%d", et, ch, key, w, h))
end
	
function inputstep(scr, evt)
	-- return an input key code
	-- handle redisplay when screen size changes.
	-- evt is passed as a parameter to avoid reallocation at each event
	while true do
		local et = lt.pollevent(evt)
		if et == 2 then --resize event
			ch = -1
			scr.w, scr.h = evt.w, evt.h
			scr:resize()
			scr:display(true) -- display error when term window is maxed
			scr:display(true) -- fixed with a 2nd display 
		elseif et == 1 then
			local ch = term.getch(evt)
			return ch
		else
			error(strf("inputstep: evt type=%d", et))
		end
	end	
	
end


------------------------------------------------------------------------
-- main

helptxt = [[
q  quit
p  popup
i  mini info
m  mini msg
h  help
]]

function test1()
	local evt = {}
	local ch = -1
	
	local et
	testinit()
	scr:init()
	
	while true do
		ch = inputstep(scr, evt)
		if ch == byte'q' then break
		elseif ch == byte'p' then 
			scr.popup.show = not scr.popup.show
			scr.popup.changed = true
			scr:display(true)
		elseif ch == byte'i' then mini:info("Mini info!!!")
		elseif ch == byte'm' then mini:msg("Mini message............")
		elseif ch == byte'h' then settext(main, helptxt)
		elseif ch == byte'a' then popup:alert(helptxt)
		end
		setevtstatus(scr, evt.type, ch, evt.key, scr.w, scr.h)
		scr:display()
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

