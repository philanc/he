-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file


--[[

=== hepack - serialize lua values 

handle only booleans, numbers, strings and simple tables ie. tables 
where keys and values are only booleans, numbers, strings and 
simple tables, and which contains no cycle.

it supports also lists (created with the he.list class constructor)

functions: 
   pack          serialize lua values as a packed binary string
   unpack        deserialize a packed binary string to a lua value

]]

local he = require'he'
local app = he.list.insert

local list = he.list


-- tags
local TMINUS_ONE = '\xff'
local TINT = '\xfe'
local TFLOAT = '\xfd'
local TSTARTL = '\xfc'
local TSTART = '\xfb'
local TSTR4 = '\xfa'
local TSTR2 = '\xf9'
local TSTR1 = '\xf8'
local TEMPTY = '\xf7'
local TEND = '\xf6'
local TTRUE = '\xf1'
local TFALSE = '\xf0'

local SPI_MAX = 0xef -- max immediate small positive integer
local DEPTH_MAX = 20  -- max depth of table imbrication (no cycle detection)

local spack, sunpack = string.pack, string.unpack
local insert = table.insert
local mtype = math.type

local function islist(t)
	local mt = getmetatable(t)
	return mt == he.list
end

local function packnumber(st, x)
	if mtype(x) == "float" then
		insert(st, TFLOAT .. spack('<d', x))
	elseif x >= 0 and x <= SPI_MAX then
		insert(st, string.char(x))
	elseif x == -1 then
		insert(st, TMINUS_ONE)
	else 
		insert(st, TINT .. spack('<j', x))
	end
end

local function packstring(st, x)
	local xln = #x
	if x == "" then
		insert(st, TEMPTY)
	elseif xln < 256 then 
		insert(st, TSTR1 .. spack('s1', x))
	elseif xln < 65536 then 
		insert(st, TSTR2 .. spack('<s2', x))
	elseif xln < 0xffffffff then 
		insert(st, TSTR4 .. spack('<s4', x))
	else
		error('cannot pack string longer than 4GB')
	end
end

local packany --forward decl

local function packtable(st, x)
	st.depth = st.depth + 1
	if st.depth > DEPTH_MAX then
		error("table max depth exceeded")
	end
	if islist(x) then 
		insert(st, TSTARTL)
		for i, e in ipairs(x) do packany(st, e)	end
	else
		insert(st, TSTART)
		for k, v in pairs(x) do packany(st, k); packany(st, v) end
	end
	insert(st, TEND)
	st.depth = st.depth - 1
end

packany = function(st, x)
	local t = type(x)
	if t == "number" then packnumber(st, x)
	elseif t == "string" then packstring(st, x)
	elseif t == "table" then packtable(st, x)
	elseif x == true then insert(st, TTRUE)
	elseif x == false then insert(st, TFALSE)
	else error("cannot pack " .. t)
	end
end

local function pack(x)
	local st = {depth = 0}
	packany(st, x)
	return table.concat(st)
end

local unpack_val = {
	[TFALSE] = false,
	[TTRUE] = true,
	[TEMPTY] = "",
	[TMINUS_ONE] = -1,
}

local unpack_fmt = {
	[TINT] = "<j",
	[TFLOAT] = "<d",
	[TSTR1] = "s1",
	[TSTR2] = "<s2",
	[TSTR4] = "<s4",
}

local unpack  --forward decl

local function unpacklist(s, i)
	local l = he.list()
	local x, i1
	while true do
		x, i1 = unpack(s, i)
		if x ~= nil then 
			insert(l, x)
			i = i1
		elseif i1 == TEND then -- end of list
			i = i + 1
			return l, i
		else 
			return nil, "unpack error"
		end
	end--while
end

local function unpacktable(s, i)
	local t = {}
	local k, v, i1, i2
	while true do
		k, i1 = unpack(s, i)
		if k == nil and i1 == TEND then return t, i + 1
		elseif k == nil then return nil, "unpack error"
		end
		v, i2 = unpack(s, i1)
		if v == nil then return nil, "unpack error"
		else
			t[k] = v
			i = i2
		end
	end--while
end

local function unpack(s, i)
	-- unpack element in s at index i
	-- return element and next position in s
	i = i or 1
	local tag = s:sub(i, i)
	local x = unpack_val[tag]
	if x ~= nil then return x, i + 1 end
	x = unpack_fmt[tag]
	if x ~= nil then return sunpack(x, s, i+1) end
	if tag == TSTARTL then return unpacklist(s, i+1)
	elseif tag == TSTART then return unpacktable(s, i+1)
	elseif tag == TEND then return nil, TEND
	end
	local b = tag:byte()
	if b <= SPI_MAX then return b, i + 1
	else return nil, "unknown tag"
	end
end --unpack()


------------------------------------------------------------------------
return  { -- hepack module
	pack = pack,
	unpack = unpack,
}

