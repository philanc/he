
-- interactive lua:
-- define some globals for convenience in interactive Lua sessions

-- make he global
he = require "he"  -- make he global

-- add he string functions to string metatable
he.extend_string()

-- make list()  global
list = he.list

-- add some convenience display functions

function ppl(lst)  print(he.l2s(lst)) end -- display a list
function ppt(lst)  print(he.t2s(lst)) end -- display a table
function ppk(t) print(he.sortedkeys(t):concat(", ")) end

pf = he.printf	-- print with a format string
px = he.px	-- print hex dump of a string
pix = he.pix	-- print hex rep of an integer
pp = he.pp	

-- require a module and make it global
function req(name) 
	local m = require(name)
	-- if name is a dotted module name (eg, "plc.rc4"), 
	-- use the last component as global name
	-- so "req('plc.rc4') would load the module as 'rc4'
	local last = name:match("^.+%.(.*)$") 
	if last then name = last end
	_G[name] = m
	return m
end

-- make all he functions global
function heglobal() 
	for k, v in pairs(he) do 
		if _G[k] and _G[k] ~= v then 
			print(k .. " is already defined in _G")
		else
			_G[k] = v 
		end
	end
end

print(he.VERSION)

