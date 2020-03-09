-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

--[[ 

=== henat module  -- wrap OS native commands

200309  cleanup. use the new he.sh()/shlines().

-- wrap InfoZip zip/unzip commands
zip
unzip
ziplist

-- wrap find  (works with old UnxUtils find command on windows)
findlist
findfiles
finddirs

]]

local he = require 'he'

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack
local strip, split = string.strip, string.split
local list = he.list
local insert, concat = table.insert, table.concat

local nat = {} -- the he.nat module
	
------------------------------------------------------------------------
--[[  notes

-- exit: 127. sh: UNKNOWN: command not found

===  180912    run a cmd with a timeout

-- on linux:  use 'timeout'

gnu coreutils timeout:
	timeout 10 cmd args
	# run cmd with a 10 secs timeout
	=> if cmd times out, return with $? == 124
	default signal is 15 (SIGTERM)
	timeout -k 10 cmd args
	=> if time out, send kill signal (9). $? == 128 + 9 == 137

busybox timeout
	timeout -t 10 cmd args
	send default signal 15 (SIGTERM)
	=> if cmd times out, return with $? == 128 + 15 == 143
	timeout -t 10 -s 9 cmd args
	send kill signal (9)
	=> if cmd times out, return with $? == 128 + 9 == 137
	example:
		timeout -t 1 sleep 2 ; echo $?

... why 124 for coreutils timeout ?!?

-- on windows: poor man's timeout
	start yourprogram.exe
	timeout /t 10
	taskkill /im yourprogram.exe

should try to identify program with pid!! exercise left to the reader!

if timeout not avail (eg before vista), can use
	ping 127.0.0.1 -n 10

spawn a cmd. echo $! displays the pid of 'sleep 10'
	/ut/s/busybox/timeout -t 1 -s 9 sh -c 'sleep 10 & echo $!' ; echo  $?
	timeout applies only to the spawning time, not the 'sleep 10'
 
 



]]
------------------------------------------------------------------------
--[[  zip, unzip, ziplist

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

function nat.ziplist(zipfn)
    local zl, msg = he.shlines('unzip -ZTs '..zipfn)
    if (not zl) or #zl < 2 then return nil, "ziplist error" end
    local nzl = reformat_ziplines(zl)
    return nzl
end

function nat.zip(fn, zipfn)
	if type(fn) == "table" then fn = table.concat(fn, " ") end
	if fn:find(' ') and not zipfn then
		return nil, "no zipfile name"
	else
		zipfn = zipfn or fn..'.zip'
	end
	return he.sh(strf('zip -q -r %s %s', zipfn, fn))
end

function nat.unzip(zipfn, dirfn)
	-- extract in dirfn or current dir if dirfn is not specified
	dirfn = dirfn or '.'
	return he.sh(strf('unzip -d %s %s', dirfn, zipfn))
end


function nat.tartos(fn)
	-- tar a list of files, return the result as a string
	-- fn is either a file/directory name ("file1"), or a 
	-- space-separated sequence of filenames("f1 f2 f3"), or
	-- a list of filenames( {"f1", "f2", "f3"} )
	-- note: '*' is not supported.
	if type(fn) == "table" then fn = table.concat(fn, " ") end
	return he.sh(strf('tar cf - %s', fn))
end



------------------------------------------------------------------------
-- find

local flist_cmd = 
	'find %s -type f -printf "%%TY%%Tm%%Td_%%TH%%TM\t%%s\t%%p\\n" '

function nat.findlist(dir)
	local ll, status = he.shlines(strf(flist_cmd, dir))
	if not ll then return nil, status end
--~ 	he.pp(ll)
	if he.windows then ll = ll:map(he.pnorm) end
--~ 	he.pp(ll)
	local mod, size, name
	local rl = list()
	for i, l in ipairs(ll) do
		mod, size, name = l:match("^(%S+)%s+(%d+)%s+(.+)$")
		rl:insert({mod, tonumber(size), name})
	end
	return rl
end

function nat.findfiles(dir)
	local cmd = 'find %s -type f '
	r, status = he.shlines(strf(cmd, dir))
	return r, status
end


function nat.finddirs(dir)
	-- find depth-first - makes it easier to delete a file tree
	-- and can be easily sorted for a more natural order
	local cmd = 'find %s -type d -depth '
	r, status = he.shlines(strf(cmd, dir))
	return r, status
end

------------------------------------------------------------------------

function nat.curl_head(url)
	return he.sh('curl -s -S -I ' .. url)
end

function nat.curl_get(url, outfile)
	outfile = outfile or '-'
	local cmd = strf("curl -sS -o %s %s", outfile, url)
	return he.sh(cmd)
end

function nat.wget(url, outfile)
	outfile = outfile or '-'
	local cmd = strf("wget -q -O %s %s", outfile, url)
	return he.sh(cmd)
end


------------------------------------------------------------------------
return nat

