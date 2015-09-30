-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[  hei.lua

Used for interactive sessions and for writing quick throw-away scripts

It requires 'he', defines it as a global, adds some utility functions 
(display, debug), defines a few globals, and adds he string functions t
o the string metatable. (see function 'extend_all' at the end)





]]

local he = require "he"

print(he.VERSION)

------------------------------------------------------------------------
-- simplistic serialization functions (list to string, table to string)
-- (convenient for debug display or limited use)

function he.l2s(t)
	-- returns list t as a string 
	-- (an evaluable lua list, at least for bool, str and numbers)
	-- !!  beware:  elements of type table are treated by t2s()  !!
	local rl = {}
	local repr, app, join = he.repr, he.list.app, he.list.join
	for i, v in ipairs(t) do 
		app(rl, (type(v) == "table") and he.t2s(v) or repr(v))
	end
	return '{' .. join(rl, ', ') .. '}'
end

function he.t2s(t)
	-- return table t as a string 
	-- (an evaluable lua table, at least for bool, str and numbers)
	-- (!!cycles are not detected!!)
	local repr, app, join = he.repr, he.list.app, he.list.join
	if type(t) ~= "table" then return repr(t) end
	if getmetatable(t) == he.list then return he.l2s(t)  end
	local rl = {}
	-- pairs() is no longer deterministic: several runs on same table
	-- return elements in different order...  (lua 5.3?)
	for i, k in ipairs(he.sortedkeys(t)) do 
		app(rl, '[' .. repr(k) .. ']=' .. he.t2s(t[k])) 
	end
	return '{' .. join(rl, ', ') .. '}'
end


------------------------------------------------------------------------
-- display / debug functions
------------------------------------------------------------------------

-- display any object

function he.pp(...)
	local repr = he.repr
	for i,x in ipairs {...} do
		if type(x) == 'table' then 
			he.printf("pp: %s   metatable: %s",  
						tostring(x), tostring(getmetatable(x)))						
			local kl = he.sortedkeys(x)
			for i,k in ipairs(kl) do
				he.printf("	| %s:  %s", repr(k), repr(x[k]))
			end
		else he.printf("pp: %s", he.repr(x))
		end
	end
end

function he.ppl(lst)  print(he.l2s(lst)) end
function he.ppt(lst)  print(he.t2s(lst)) end
function he.ppk(dic)  print(he.l2s(he.sortedkeys(dic))) end

function he.printf(...) print(string.format(...)) end
function he.errf(...) error(string.format(...)) end

--
he.prsep_ch = '-'  -- character used for separator line
he.prsep_ln = 60  -- length of separator line
--
function he.prsep(...) 
--- print a separator line, then print arguments
	print(string.rep(he.prsep_ch, he.prsep_ln)) 
	if select('#', ...) > 0  then  print(...)  end
end


--
------------------------------------------------------------------------
-- elapsed time -- is os.clock() measuring elapsed or cpu time? keep it?

local _hei_load_clock = os.clock()
local _hei_load_time = os.time()

function he.elapsed()
	-- return elapsed time since 'he' was loaded (in seconds)
	-- and cpu time ... or whatever os.clock() refers to :-)
	return (os.time() - _hei_load_time), (os.clock() - _hei_load_clock)
end


function he.print_elapsed(msg) 
-- display elapsed time
	local duration, cpu = he.elapsed()
	print(msg or 'Elapsed:', duration, cpu)  
end

------------------------------------------------------------------------

function he.extend_all()
	-- extend string module with he string functions
	string.startswith  =  he.startswith
	string.endswith  =  he.endswith
	string.split  =  he.split
	string.lines = he.lines
	string.lstrip  =  he.lstrip
	string.rstrip  =  he.rstrip
	string.strip  =  he.strip
	string.stripnl  =  he.stripnl
	string.stripeol  =  he.stripeol
	-- export he to global env
	_G.he = nil
	_G.he = he
	-- export some he defs to global env
	_G.pp, _G.ppl, _G.ppt = he.pp, he.ppl, he.ppt
	_G.strf, _G.printf = string.format, he.printf
	_G.list = he.list
end


------------------------------------------------------------------------

he.extend_all()

------------------------------------------------------------------------


