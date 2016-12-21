-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file


--[[
heserial - serialize lua values 
      (booleans, numbers, strings and simple tables and lists)
 
handle only simple tables ie. tables where keys and values are only 
booleans, numbers, strings and simple tables, and which contains no cycle.

it supports also lists (created with the he.list class constructor)

functions: 

   serialize     serialize a simple table as a string
   deserialize   parse a string, return a simple table

   fput          serialize a simple table and write it to a file
   fget          read a serialized table from a file and deserialized it

]]

local he = require'he'
local app = he.list.app

local list = he.list

local function serialize(x)
-- produce a lua source representation of x
-- assume x contains only booleans, numbers, strings and tables 
--	tables can be he.list or raw tables 
--	(metatables are ignored if element are not he.list)
--	assume there is no cycle/recursive data definition
	local strf = string.format
	if type(x) == 'number' or type(x) == 'boolean' then
		return tostring(x)
	elseif type(x) == 'string' then
		return string.format("%q", x) 
	elseif type(x) == 'table' then
		local mt = getmetatable(x)
		local prefix
		local rl = list()
		if mt == he.list then  -- serialize as a list (only array part)
			prefix = 'list{\n' 
			for i,v in ipairs(x) do 
				app(rl, serialize(v)); app(rl, ',\n')
			end
			return prefix .. rl:join().. '}'
		end
		-- serialize as a regular table (all keys)
		prefix = '{\n' 
		for k,v in pairs(x) do 
			app(rl, strf('[%s]=%s,\n', serialize(k), serialize(v)))
		end 
		return prefix .. rl:join().. '}'
	else
		error('serialize: unsupported type ' .. type(x))
	end--if type
end--serialize()

local function deserialize(s)
-- return the value of some lua expression serialized by serialize()
-- !! 's' is evaluated => major security risk if s is not safe !!
-- !! => use it only for data produced by serialize()          !!
	local x
	if _VERSION == "Lua 5.1" then 
		local chunk = assert(loadstring('return ' .. s), 
			"deserialize: string parse error")		
		local e = {list=he.list}
		local f = setfenv(chunk, e)
		x = f()
	else 
		local e = {list=he.list}
		local f = assert(
			load('return ' .. s, "(heserial)", "t", e), 
			"deserialize: string parse error")
		x = f()
	end
	return x
end--deserialize()

local function fput(fname, x, encode)
	-- serialize x, write to file 'fname'. 
	-- encode is an optional encoding function (closure).  
	-- if provided, it is applied to the serialized data. 
	-- (encode can be used to compress and/or encrypt the serialized data)
	local s = serialize(x)
	if encode then s = encode(s) end
	he.fput(fname, s)
end--fput()

local function fget(fname, decode)
	-- read serialized data from file 'fname' and returned deserialized data.
	-- decode is an optional decoding function (closure).  
	-- if provided, it is applied to the serialized data. 
	local s = he.fget(fname)
	if decode then s = decode(s) end
	return deserialize(s)
end--fget()

------------------------------------------------------------------------
return  { -- heserial module
	serialize = serialize,
	deserialize = deserialize,
	fput = fput,
	fget = fget,
}

