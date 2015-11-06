-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[	termapp.lua

(non usable)

]]


------------------------------------------------------------------------
-- some local definitions

local lt = require 'ltbox'
local term = require 'term'
local he = require 'he'

local colors, keys = term.colors, term.keys

local strf = string.format
local byte, char, sub = string.byte, string.char, string.sub

local app, concat = table.insert, table.concat

local list, class = he.list, he.class

------------------------------------------------------------------------
-- utilities

function paintline(b)
	term.putfiller(b, b.fill)
	term.putstring(b.line, b.x, b.y, b.xm, b.attr)
	b.changed = true
end

function evtstatus(ta, et, code, key, w, h)
	ta.msep.line = strf(
		"et:%d  ch:%d  key:%d  w:%d  h:%d", 
		et, code, key, w, h)
	ta.msep.changed = true
	
end
------------------------------------------------------------------------
-- editline functions

local editline = class()

function editline:init(s, x, y, xm, attr)
	-- s: initial value of string
	self.attr = attr or 0
	self.x, self.y, self.xm, self.cur = x, y, xm
	-- sl is a list of char codes
	local sl = list(); for i = 1, #s do sl:app(byte(s, i)) end --FIXME UTF8
	self.sl = sl
	-- c is the cursor in the line being edited
	self.c = 1
	self.cl = 1  --index of the leftmost char (horiz scroll.)
	self.cx = x  -- the screen cursor
	return self
end

function editline.redisplay(e)
	local y, attr = e.y, e.attr
	local sx = e.x
	for i, ch in ipairs(e.sl) do
		lt.putcell(sx, y, ch | attr)
		sx = sx + 1  --FIX tab and other multicell chars
		if sx >= e.xm then break end
	end
	while sx <= e.xm do --erase remaining cells to end of box
		lt.putcell(sx, y, 32 | attr)
		sx = sx + 1
	end
	-- set screen cursor
	lt.setcursor(e.cx, e.y)
	lt.present()
end

function editline.ateol(e)
	--return true if string cursor is at end of line
	return (e.c == #e.sl + 1)
end

function editline.atbol(e)
	-- return true if string cursor is at beginning of line 
	return (e.c == 1)
end

function editline.forward(e)
	if e:ateol() then return false end -- cannot move forward
	e.c = e.c + 1
	e.cx = e.cx + 1 -- to fix for tabs and other multicell chars!!!
	-- TODO add horiz scroll here
	return true
end

function editline.backward(e)
	if e:atbol() then return false end -- cannot move backward
	e.c = e.c - 1
	e.cx = e.cx - 1
	-- TODO add horiz scroll here
	return true
end

function editline.insertchar(e, ch)
	-- delete char ch at string cursor, don't move
	table.insert(e.sl, e.c, ch)
	return e:forward()
end
	
function editline.deletechar(e, ch)
	-- insert char ch at string cursor, move forward
	if e:ateol() then return false end
	table.remove(e.sl, e.c)
	return true
end

function editline.killeol(e)
	-- delete all chars from cursor to end of line
	while e:deletechar() do end
	return true
end

function editline.backspace(e)
	return e:backward() and e:deletechar()
end

function editline.goeol(e)
	while e:forward() do end
	return true
end

function editline.gobol(e)
	while e:backward() do end
	return true
end

function editline.getline(e)
	-- return the line as a string
	local t = {}
	for i, ch in ipairs(e.sl) do t[i] = char(ch) end --FIX UTF8
	return concat(t)
end

function editline.docmd(e, ch)
	if ch >= 32 and ch < 256 then e:insertchar(ch)
	elseif ch==8  then e:backspace()
	elseif ch==1 or ch==keys.khome  then e:gobol()		-- ^A
	elseif ch==5 or ch==keys.kend   then e:goeol()		-- ^E
	elseif ch==2 or ch==keys.kleft  then e:backward()	-- ^B
	elseif ch==6 or ch==keys.kright then e:forward()	-- ^F
	elseif ch==4 or ch==keys.kdel   then e:deletechar()	-- ^D
	elseif ch==11                   then e:killeol()	-- ^K
	end
end

function editline.edit(e)
	local evt = {}
	local et, ch
	e:goeol() -- start at end of an initial string
	e:redisplay()
	while true do
		et = lt.pollevent(evt)
		-- ignore resize events
		if et==1 then
			ch = term.getch(evt)
			if ch==27 or ch==7 then return nil end --ESC, ^G
			if ch==13 then return e:getline() end  --RET
			e:docmd(ch)
			e:redisplay()
		end
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

function ta.miniprompt(ta, prompt, default)
--~ 	if default then prompt = strf("%s [%s] ", prompt, default) end
	local el = editline():init(default, ta.mini.x, ta.mini.y, ta.mini.xm)
	local value = el:edit()
	return value
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
	app.status = strf(" ch:%d  w:%d  h:%d ", code, app.ta.scrw, app.ta.scrh)
	if code == byte'q' then return 2 -- app quit
	elseif code == byte'i' then app.ta:miniinfo("Mini info!!!") 
	elseif code == byte'm' then app.ta:minimsg("Mini msg........") 
	elseif code == byte'r' then 
		s = app.ta:miniprompt("P", "try to edit")
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
