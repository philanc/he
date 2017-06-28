-- Coppyright (c) 2009-2011  Ph. Leblanc 

--[[  

=== zip/unzip wrapping functions - requires InfoZip zip and unzip commands

]]
------------------------------------------------------------------------
local he = require 'he'

local hezip = {} -- the hezip module

local strip, split = string.strip, string.split
local list = he.list
local insert, concat = table.insert, table.concat


--[[  

unzip zipinfo format  (same for linux and win32??)

on win32, 091130:

D:\Temp\hezip>unzip -ZTs d2
Archive:  d2.zip   717 bytes   3 files
drwx---     2.3 ntf        0 bx stor 20091130.124402 d/
-rw-a--     2.3 ntf        8 tx stor 20091130.124402 d/ab
-rw-a--     2.3 ntf        9 tx stor 20091130.124402 d/bef
3 files, 17 bytes uncompressed, 17 bytes compressed:  0.0%

]]

local function reformat_ziplines(ziplines)
    -- reformat unzip -ZTs  output  (see example above)
    -- (zipinfo list format - hopefully identical between linux and win32)
    local nzt = {}
    local reinfo = ("^%S+%s+%S+%s+%S+%s+(%d+) %S+ %S+ "
            .. "(%d%d%d%d%d%d%d%d%.%d%d%d%d%d%d) (%S.+[^/])$")
    local siz, tim, pnam
    for i, s in ipairs(ziplines) do
        siz, tim, pnam = string.match(s, reinfo)
        if pnam and not he.endswith(pnam, '/') then
            siz = string.format("%9s", siz)
            tim = string.gsub(tim, "%.", "-")
            insert(nzt, {tim, siz, pnam})
        end
    end
    table.sort(nzt, function(a,b) return a[3]<b[3] end)
	local function mkl(t) return table.concat(t, ' ') end
    return list.map(nzt, mkl)
end

function hezip.ziplist(zipfn)
    local zl = he.shlines('unzip -ZTs '..zipfn)
    if #zl < 2 then return nil end
    local nzl = reformat_ziplines(zl)
    return nzl
end

function hezip.zip(fn, zipfn)
    zipfn = zipfn or fn..'.zip'
--~     ret = os.execute(string.format('zip -r %s %s', zipfn, fn))
    local ret = he.shell(string.format('zip -q -r %s %s', zipfn, fn))
    return ret
end

function hezip.unzip(zipfn, dirfn)
	-- extract in dirfn or current dir if dirfn is not specified
	dirfn = dirfn or '.'
    local ret = he.shell(string.format('unzip -d %s %s', dirfn, zipfn))
    return ret
end


------------------------------------------------------------------------
return hezip

