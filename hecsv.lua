-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[ 

hecsv - comma separated value (CSV) list processing

-- functions:

  parse		parse a string containing CSV-encoded data
			return a list of records, each record being a list of fields

  l2line	return a csv string representation for a list (one csv record)

  ll2csv	return a csv string representation for a list of lists
			(a list of csv records)

  options	a table containing field, record and string delimiters

The default options and behavior is compatible with MS Excel csv format.
			
--

this module uses:  he

	
]]
------------------------------------------------------------------------
local he = require 'he'

local list = he.list

------------------------------------------------------------------------
local csv = {}  -- the csv  module

local options = {
    RS = "\r?\n",  -- record separator. 
    FS = ",",  -- field separator
    SD = [["]],  -- string delimiter
    ESD = [[""]], -- escaped string delimiter (within a string)
}
csv.options = options

local function readstring(src, ic)
    local SD, ESD = options.SD, options.ESD
    local isd, jsd, iesd, jesd
    local i = ic
    local s
    while true do
        isd,jsd = string.find(src, SD, i)
        if not isd then error('string not closed')  end
        iesd,jesd = string.find(src, ESD, i)
        if not iesd or isd < iesd then
            -- isd points at ending string delim.
            s = string.sub(src, ic, isd-1)
            s = string.gsub(s, ESD, SD)
            return s, jsd+1
        else
            -- skip the escaped string delim
            i = jesd + 1
        end
    end
end

--- find next sep (either FS or RS or nil)
-- return sep 1st and last indexes, lastfield indicator, lastrecord indicator
-- lastrecord is true if no more RS ahead
-- lastfield is true if no more FS or RS ahead
local function findsep(src, i)
    local SD, FS, RS = options.SD, options.FS, options.RS
    local ifs, jfs, irs, jrs
    local lastfield, lastrecord --booleans
    irs,jrs = string.find(src, RS, i)
    lastrecord = not irs
    ifs,jfs = string.find(src, FS, i)
    lastfield = not ifs or (irs and  irs < ifs)
    if lastrecord and lastfield then
        return #src+1, #src+1, lastfield, lastrecord
    elseif lastfield then
        return irs, jrs, lastfield, lastrecord
    else
        return ifs, jfs, lastfield, lastrecord
    end
end

--- read a field, skip next FS if any
-- return 
--  field value, 
--  next position in source, 
--  true if last field of record, else false
local function readfield(src, ic)
    local SD, FS, RS = options.SD, options.FS, options.RS
    local i,j, ifs, jfs, irs, jrs
    local lastfield, lastrecord
    local s
    i,j = string.find(src, SD, ic)
    if i == ic then
        s, i = readstring(src, j+1)
        i, j, lastfield, lastrecord = findsep(src, i)
        return s, j+1, lastfield, lastrecord
    else
        i, j, lastfield, lastrecord = findsep(src, ic)
        s = string.sub(src, ic, i-1)
        return s, j+1, lastfield, lastrecord 
    end
end

local function readrecord(src, ic)
    local fl = list()
    local lastfield, lastrecord
    local s
    local i,j
    i = ic
    while true do
        s, j, lastfield, lastrecord = readfield(src, i)
        fl:app(s)
        if lastfield then break end
        i = j
    end
    return fl, j, lastrecord
end

function csv.parse(src)
    local rl = list()
    local i = 1
    local r
    local last = false
    while not last do
        r, i, last = readrecord(src, i)
        rl:app(r)
    end
    return rl
end

function csv.dump(t)
    for i,r in ipairs(t) do
        print('#', i, he.l2s(r))
    end
end

function csv.l2line(lst)
	-- return a csv line representation for a list (one csv record)
	local l = list()
	local  es
	for i, e in ipairs(lst) do
		es  = tostring(e)
		if es:find[["]] or es:find[[,]] then
			es:gsub([["]], [[""]])
			es  = [["]] .. es .. [["]]
		end
		l:app(es)
	end--for
	return l:join(',')
end

function csv.ll2csv(lst)
	-- return a string that is a csv representation of a list of lists
	-- all elements of lst must be lists
	local l = list()
	for i, li in ipairs(lst) do
		l:app(csv.l2line(li))
	end--for
	return l:join('\n')
end

------------------------------------------------------------------------
return csv

