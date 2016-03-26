-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[	lc.lua

(non usable)

]]


------------------------------------------------------------------------
-- some local definitions

local lt = require 'ltbox'
local term = require 'term'
local termapp = require 'termapp'
local he = require 'he'

local colors, keys = term.colors, term.keys

local strf = string.format
local byte, char, sub = string.byte, string.char, string.sub

local app, concat = table.insert, table.concat

local list, class = he.list, he.class

------------------------------------------------------------------------
-- lc application

local lc = {}  

local theme = {
	main = 0,
	sel = colors.reverse,
	vsep = colors.bgyellow | colors.black,
	msep = colors.bggreen | colors.black,
}

------------------------------------------------------------------------
-- utilities

mini = class()

function mini.init(m, sep, prompt)
	m.sep = sep or ""
	m.prompt = prompt or "> "
end

function mini.resize(m, w, h)
	m.x, m.y, m.xm, m.ym = 1, h-1, w, h
end

function mini.paint(m, force)
	if mini.changed or force then
		term.putstring(m.sep, m.x, m.y, m.xm, theme.msep, true)
		term.putstring(m.prompt, m.x, m.ym, m.x+#prompt-1, theme.main)
		mini.changed = false
		lt.present()
		if m.eline then m.eline:redisplay() end	
end

function mini.handle XXXXXXXXXXXXXXXXXX



------------------------------------------------------------------------
-- lc main functions



function lc.init()
	-- initialize screen
	lt.init()
	lc.scrw, lc.scrh = lt.screen_wh()
	-- boxes' dim will be set by resizeall()
	lc.leftpane = term.newbox(1,1,1,1,lc.theme.main)
	lc.rightpane = term.newbox(1,1,1,1,lc.theme.main)
	lc.vsep = term.newbox(1,1,1,1,lc.theme.vsep)
	lc.msep = term.newbox(1,1,1,1,lc.theme.msep)
	lc.mini = term.newbox(1,1,1,1,lc.theme.main)
	lc.resizeall()
	
	lc.focus = leftpane
	lc.other = rightpane
	
end --lc.init

function lc.resizeall()
	local w, h = ta.scrw, ta.scrh
	local lp, rp, vs = lc.leftpane, lc.rightpane, lc.vsep, 
	local ms, mi = lc.msep, lc.mini
	lp.x, lp.y, lp.xm, lp.ym = 1, 1, w//2-1, h-2
	rp.x, rp.y, rp.xm, rp.ym = w//2+1, 1, w, h-2
	vs.x, vs.y, vs.xm, vs.ym = w//2, 1, w//2, h-2
	ms.x, ms.y, ms.xm, ms.ym = 1, h-1, w, h-1
	mi.x, mi.y, mi.xm, mi.ym = 1, h, w, h
end

function lc.shutdown()
	if lc.shutdown_done then 
		error("shutdown already done")
	else
		lt.shutdown()
		lc.shutdown_done = true
	end
end

function lc.mainloop()
	lc.init()
	local evt = {}
	while true do
		local code = lc.inputstep(evt)
		-- debug
		evtstatus(evt.type, code, evt.key, ta.scrw, ta.scrh)
		local res = lc.handle(code)
		if res == 2 then break end
		if res == 1 then lc.changed = true end
		lc.redisplay()
	end
	lc.shutdown()
end	

function lc.run()
	local ok, msg = xpcall(lc.mainloop, debug.traceback)
	-- alt error handler for debug: debug.debug
	if not ok then 
		lc.shutdown()
		print(msg)
		os.exit(1)
	end
end





	

	
------------------------------------------------------------------------

ta = {} -- the termapp module / singleton object

--[[

functions to be defined by application object app
app.init = function(app)
app.handle = function(app, keycode)  end
	-- return 0: no change, 1: some change, 2: quit
app.resize = function(app, w, h) end
app.paint = function(app, force) end 

app.ta: reference to the termapp object (set by ta.register())
app.changed: used by ta.redisplay() - set by app or by ta input loop
             based on app.handle() return value

]]

-- termapp boxes
ta.msep = term.newbox(1, 1, 1, 1) -- actual dimensions to be set by resize()
ta.msep.attr = colors.bggreen | colors.black
ta.msep.line = "(msep)"
ta.mini = term.newbox(1, 1, 1, 1) -- actual dimensions to be set by resize()
ta.mini.attr = 0
ta.mini.selattr = colors.reverse
ta.mini.line = "(mini)"

-- public functions

function ta.register(ta, app)
	ta.app = app
	app.ta = ta
	app.changed = true
end

function ta.init(ta)
	-- initialize screen
	lt.init()
	-- set dimensions
	ta.scrw, ta.scrh = lt.screen_wh()
	ta:resizeall()
	-- set attributes and content
	ta.app:init()
	-- then display all
	ta:redisplay(true)
end

function ta.resizeall(ta)
	local w, h = ta.scrw, ta.scrh
	local ms, mi = ta.msep, ta.mini
	ms.x, ms.y, ms.xm, ms.ym = 1, h-1, w, h-1
	mi.x, mi.y, mi.xm, mi.ym = 1, h, w, h
	-- app can use any screen location between (1, 1) and (w, h-2)
	ta.app:resize(w, h-2) 
end

function ta.redisplay(ta, force)
	if ta.msep.changed or force then 
		paintline(ta.msep)
		ta.msep.changed = false
		lt.present()
	end
	if ta.mini.changed or force then 
		paintline(ta.mini)
		ta.mini.changed = false
		lt.present()
	end
	-- main pane is completely handled by the application
	-- just return true if something has changed so that it is 
	-- pushed on screen
	if ta.app.changed or force then 
		ta.app:paint(force)
		lt.present()
	end
end

-- shutdown
ta.shutdown_done = false

function ta.shutdown(ta)
	if ta.shutdown_done then 
		error("shutdown already done")
	else
		lt.shutdown()
		ta.shutdown_done = true
	end
end



function ta.minisep(ta, s)
	ta.msep.line = s
	ta.msep.changed = true
	ta:redisplay()
end

function ta.miniinfo(ta, s)
	ta.mini.line = s
	ta.mini.changed = true
	ta:redisplay()
end

function ta.minimsg(ta, s)
	local ch
	local evt = {}
	ta.mini.line = s .. " [ok]"
	ta.mini.changed = true
	ta:redisplay()
	repeat ch = ta:inputstep(evt) until ch==13 or ch==27
	ta:miniinfo("")
end

function ta.miniprompt0(ta, prompt, default)
--~ 	if default then prompt = strf("%s [%s] ", prompt, default) end
	local el = editline():init(default, ta.mini.x, ta.mini.y, ta.mini.xm)
	local value = el:edit()
	return value
end

function ta.miniprompt(ta, prompt, default)
--~ 	if default then prompt = strf("%s [%s] ", prompt, default) end
	default = default or ""
	ta:miniinfo(prompt)
	local mi = ta.mini
	local promptsize = #prompt -- number of cells on screen FIX UTF8, tab,... 
	local el = editline():init(default, mi.x+promptsize, mi.y, mi.xm)
	local evt = {}
	local et, ch
	el:goeol() -- start at end of an initial string
	el:redisplay()
	while true do
		term.setcursor(0, 0)  -- no dangling cursor in case of exit
		ch = ta:inputstep(evt)
		if ch==27 or ch==7 then return nil end --ESC, ^G
		if ch==13 then return el:getline() end  --RET
		if ch==-2 or ch==12 then 
			el:setbox(mi.x+promptsize, mi.y, mi.xm, mi.attr)
		else 
			el:docmd(ch)
		end
		el:redisplay() -- (including show cursor)
	end
end


function ta.inputstep(ta, evt) 
	-- return an input key code
	-- handle redisplay when screen size changes.
	-- evt is passed as a parameter to avoid reallocation at each event
	local et, ch
	assert(type(evt)=="table", "inputstep: evt not allocated")
	while true do
		et = lt.pollevent(evt)
		if et == 2 then --resize event
			ta.scrw, ta.scrh = evt.w, evt.h
			ta:resizeall()
			ta:redisplay(true) -- display error when term window is maxed
			ta:redisplay(true) -- fixed with a 2nd display 
			ch = -2
			return ch -- allow the app to know that screen dim have changed
		elseif et == 1 then
			ch = term.getch(evt)
			return ch
		else
			error(strf("inputstep: evt type=%d", et))
		end
	end	
end --inputstep

function ta.runapp(ta, app)
	ta:register(app)
	ta:init()
	-- main input loop
	evt = {}
	while true do
		local code = ta:inputstep(evt)
		-- debug
		evtstatus(ta, evt.type, code, evt.key, ta.scrw, ta.scrh)
		local res = ta.app:handle(code)
		if res == 2 then break end
		if res == 1 then ta.app.changed = true end
		ta:redisplay()
	end
	ta:shutdown()
end

function ta.run(ta, app)
	local ok, msg = xpcall(ta.runapp, debug.traceback, ta, app)
--~ 	local ok, msg = xpcall(ta.runapp, debug.debug, ta, app)
	if not ok then 
		ta:shutdown()
		print(msg)
		os.exit(1)
	end
end

-- end of ta definitions

------------------------------------------------------------------------
-- test app

helptxt = [[
q  quit
p  popup
i  mini info
m  mini msg
h  help
]]
--[[
functions to be defined by application object app
app.init = function(app)
app.handle = function(app, keycode)  end
	-- return 0: no change, 1: some change, 2: quit
app.resize = function(app, w, h) end
app.paint = function(app, force) end 
]]

app = {}

function app.init(app)
	app.attr = colors.red | colors.bold
	app.fill = 183
	app.status = "Hello from app!!!"
end

function app.resize(app, w, h)
	app.x = 1; app.y = 1; app.xm = w; app.ym = h
end

function app.paint(app, force)
	term.putfiller(app, app.fill) 
	local x, xm = app.xm-#app.status+1, app.xm
	term.putstring(app.status, x, 1, xm, colors.green)
	--
end

function app.handle(app, code)
	local s
	app.status = strf(" ch:0x%02x  w:%d  h:%d ", code, app.ta.scrw, app.ta.scrh)
	if code == byte'q' then return 2 -- app quit
	elseif code == byte'a' then 
		app.ta:miniinfo("input/alt mode: " .. lt.inputmode()) 
		lt.inputmode(2)
	elseif code == byte'i' then app.ta:miniinfo("Mini info!!!") 
	elseif code == byte'm' then app.ta:minimsg("Mini msg........") 
	elseif code == byte'r' then 
		s = app.ta:miniprompt("edit: ")
		app.ta:miniinfo("result is: "..tostring(s) )
	elseif code == byte'e' then zza=zzb.zzc -- test error msg
	end
	return 0
end

------------------------------------------------------------------------
-- run test app
ta:run(app)
--~ he.pp(ta)
print("done.")
