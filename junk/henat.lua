-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

--[[ 

=== henat module  -- wrap OS native commands

-- Complement os.execute() - (poor man's popen3, popen4)
execute2  same as execute, with stdin and stdout redirected to tmp files
execute3  same as execute, with stdin, stdout and stderr redirected 
exec      convenience function (wraps execute2) 

-- wrap InfoZip zip/unzip commands
zip
unzip
ziplist

-- wrap find  (works with old UnxUtils find command on windows)
findfiles
finddirs

-- wrap sdelete, shred/rm
sdelete

-- wrap hashdeep commands
md5deep
sha256deep


]]

local he = require 'he'
--~ he.interactive()

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack
local strip, split = string.strip, string.split
local list = he.list
local insert, concat = table.insert, table.concat

local tmpname = he.tmpname  

------------------------------------------------------------------------

local function execute2(cmd, strin)
	-- invoke os.execute(). Supply string strin as stdin and return 
	-- stdout and stderr merged in one string in addition to 
	-- the 3 os.execute() return values
	-- strin is optional. If not provided, no stdin redirection
	-- is performed.
	local tmpin = tmpname()
	local tmpout = tmpname()
	local cmd2
	if strin then
		he.fput(tmpin, strin)
		cmd2 = strf("%s <%s >%s 2>&1 ", cmd, tmpin, tmpout)
	else 
		cmd2 = strf("( %s ) >%s 2>&1 ", cmd, tmpout)
	end
	local succ, exit, status = os.execute(cmd2)
	local strout = he.fget(tmpout)
	if strin then os.remove(tmpin) end
	os.remove(tmpout)
	return succ, exit, status, strout
end

local function execute3(cmd, strin)
	-- invoke os.execute(). Supply string strin as stdin and return stdout 
	-- and stderr as strings in addition to the 3 os.execute() return values
	-- strin is optional. If not provided, no stdin redirection
	-- is performed.
	local tmpin = tmpname()
	local tmpout = tmpname()
	local tmperr = tmpname()
	local cmd3
	if strin then
		he.fput(tmpin, strin)
		cmd3 = strf("( %s ) <%s >%s 2>%s", cmd, tmpin, tmpout, tmperr)
	else 
		cmd3 = strf("( %s ) >%s 2>%s", cmd, tmpout, tmperr)
	end
	local succ, exit, status = os.execute(cmd3)
	local strout = he.fget(tmpout)
	local strerr = he.fget(tmperr)
	if strin then os.remove(tmpin) end
	os.remove(tmpout)
	os.remove(tmperr)
	return succ, exit, status, strout, strerr
end

local function lines(s)
	-- return an iterator returning the lines in s
	-- usage: for l in lines(text) do . . . end
	-- note: if the last line doesn't end with CRLF or LF 
	-- it is not returned. (shouldn't be a problem with 
	-- output of shell commands -- else, use he.lines())
	return string.gmatch(s, "(.-)[\r]?\n") 
end

local function exec(cmd, strin)
	-- convenience function. execute a command (with execute2())
	-- on success, return the stdout
	-- on failure, return nil, msg
	-- msg is "<status>. <stdout/stderr>"
	-- <status> is <exit>: <status code or signal number>
	-- <exit> is either "exit" or "signal", as returned by os.execute()
	-- strin is optional (see execute2())
	local succ, exit, status, strout = execute2(cmd, strin)
	if succ then return strout end
	return nil, strf("%s: %s. %s", exit, tostring(status), strout)
end

-- exit: 127. sh: UNKNOWN: command not found

local function shcmd(cmd)
	-- wrap he.shell
	-- redirect stderr to stdin
	-- *** => cmd should not include redirections ***
	-- return nil, stderr in case of error (status not 0)
	cmd = cmd .. " 2>&1 " -- should work on unix and recent windows (win7?)
	local r, m = he.shell(cmd)
	if r and (m ~= 0) then 
		m = r; r = nil 
	elseif m == 0 then
		m = nil
	end
	return r, m
end

	
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

local function ziplist(zipfn)
    local zl = he.shlines('unzip -ZTs '..zipfn)
    if #zl < 2 then return nil end
    local nzl = reformat_ziplines(zl)
    return nzl
end

local function zip(fn, zipfn)
    zipfn = zipfn or fn..'.zip'
--~     ret = os.execute(string.format('zip -r %s %s', zipfn, fn))
    local ret = he.shell(string.format('zip -q -r %s %s', zipfn, fn))
    return ret
end

local function unzip(zipfn, dirfn)
	-- extract in dirfn or current dir if dirfn is not specified
	dirfn = dirfn or '.'
    local ret = he.shell(string.format('unzip -d %s %s', dirfn, zipfn))
    return ret
end

------------------------------------------------------------------------
-- find

local flist_cmd = 
	'find %s -type f -printf "%%TY%%Tm%%Td_%%TH%%TM\t%%s\t%%p\n" '

local function flist(dir)
	return shcmd(strf(flist_cmd, dir))
end

local function findfiles(dir)
	local cmd = 'find %s -type f '
	r, m = shcmd(strf(cmd, dir))
	return r, m
end


local function finddirs(dir)
	-- find depth-first - makes it easier to delete a file tree
	-- and can be easily sorted for a more natural order
	local cmd = 'find %s -type d -depth '
	r, m = shcmd(strf(cmd, dir))
	return r, m
end


-- [[

print(
--~ 111 .. 
--~ zip('galzook')
--~ flist'/root/conf'
--~ flist'he.luaxzx'
--~ flist'he.luaxzx'
--~ flist'he.lua'
--~ flist'.'
--~ finddirs'..'
findfiles'.'
--~ .. 222
)


-- ]]

------------------------------------------------------------------------
return {
	execute2 = execute2,
	execute3 = execute3,
	lines = lines,
	exec = exec,
	--
	zip = zip, 
	unzip = unzip, 
	ziplist = ziplist, 
	--
	flist = flist,
	
}

