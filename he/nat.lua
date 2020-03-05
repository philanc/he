-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

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

local function shell(cmd, opt)
	-- execute the command 'cmd' in a subprocess with popen()
	-- (see the Lua os.popen() description) 
	-- opt is an optional table with additional optional parameters.
	-- return succ, code, strout, strerr  where succ is a boolean
	-- (nil if the command failed or true), code is an integer status 
	-- code. it is either the command exit code if the process exited, 
	-- or a signal code if the process was interrupted by a signal
	-- (the signal code is the signal value + 256).
	-- 'strout' and 'strerr' are the command stdout and stderr 
	-- returned as strings. They are captured in temp files or 
	-- directly by popen() - see the options in the 'opt' table.
	--
	-- opt.cwd     
	--   if defined, change working dir to opt.cwd value 
        --   before running the command (default is no change dir)
	-- opt.strin
	--   a string that is passed to the command as stdin
	-- opt.stdin (ignored if opt.strin is not defined)
	--   either empty (nil) or the string 'tmp'
	--   if 'tmp', the value of opt.strin is copied to a temp file
	--   and the command stdin is redirected to the temp file.
	--   The temp file is removed after execution.
	--   if opt.stdin is empty, the opt.strin value is written 
	--   to the popen pipe as the command stdin (popen mode 'w').
 	-- opt.stdout  
	--   either empty (nil) or the string 'tmp'
	--   if 'tmp', the command stdout is captured in a temp file and 
	--   returned. The temp file is removed after execution
	-- opt.stderr
	--   either empty (nil) or 'tmp' or 'null' or 'stdout'
	--   if 'tmp', the command stdout is captured in a temp file and 
	--   returned. The temp file is removed after execution.
	--   if 'null', the command stderr is redirected to /dev/null.
	--   if 'stdout', the command stderr is redirected to stdout
	--   (equivalent to appending " 2>&1 " after the command)
	--
	local strout, strerr = "", ""
	local redir_in, redir_out, redir_err = "", "", ""
	local tmpin, tmpout, tmperr
	
	-- the shell command template
	local shfmt = [[
		set -e
		{
		%s
		%s
		} %s %s %s ]]

	-- optional cd before running the command
	local chdir = ""
	if opt.cwd then chdir = "cd " .. opt.cwd end
	
	local mode = 'r' -- the popen() mode
	
	-- setup stdin redirection, if needed
	if opt.strin then
		if not opt.stdin then 
			mode = 'w'
		elseif opt.stdin == 'tmp' then
			tmpin = tmpname()
			he.fput(tmpin, opt.stdin)
			redir_in = strf(" <%s ", tmpin)
		else
			return nil, "invalid opt.stdin"
		end
	end

	-- setup stderr redirection, if needed
	if opt.stderr == "tmp" then
		tmperr = tmpname()
		redir_err = strf(" 2>%s ", tmperr)
	elseif opt.stderr == "null" then 
		redir_err = " 2> /dev/null "
	elseif opt.stderr == "stdout" or not opt.stderr then 
		redir_err = " 2>&1 "
	end
	
	-- setup stdout redirection, if needed
	if opt.stderr == "tmp" then
		tmpout = tmpname()
		redir_out = strf(" >%s ", tmpout)
	end
	
	-- execute command
	local shcmd = strf(shfmt, chdir, cmd, redir_in, redir_out, redir_err) 
	local succ, exit, status = os.execute(shcmd)	
	
	XXXXXXXXXXXX  repl execute with popen. read/write as needed
	
	-- collect stdout, stderr and remove temp files if any
	if tmpin then os.remove(tmpin) end
	if tmpout then
		strout = he.fget(tmpout)
		os.remove(tmpout)
	end
	if tmperr then
		strerr = he.fget(tmperr)
		os.remove(tmperr)
	end
	
	-- return results
	if exit == "signal" then status = status + 256 end
	return succ, status, strout, strerr

end--shell()

local function execute(cmd, opt)
	local shs = [[
	  he_nat_func() {
		set -e
		%s
		%s
	  }
	  he_nat_func %s %s %s
	]]
	local chdir = ""
	if opt.cwd then chdir = "cd " .. opt.cwd end
	
	local redir_in, redir_out, redir_err = "", "", ""
	local tmpin, tmpout, tmperr
	tmpout = tmpname()
	redir_out = strf(" >%s ", tmpout)
	if opt.stdin then 
		tmpin = tmpname()
		he.fput(tmpin, opt.stdin)
		redir_in = strf(" <%s ", tmpin)
	end
	if opt.stderr == "yes" then
		tmperr = tmpname()
		redir_err = strf(" 2>%s ", tmperr)
	elseif opt.stderr == "null" then 
		redir_err = " 2> /dev/null "
	elseif opt.stderr == "no" then 
		redir_err = ""
	elseif (opt.stderr == "out") or not opt.stderr then 
		redir_err = " 2>&1 "
	end
	shs = strf(shs, chdir, cmd, redir_in, redir_out, redir_err) 
	local succ, exit, status = os.execute(shs)
	local strout, strerr
	if tmpin then os.remove(tmpin) end
	strout = he.fget(tmpout)
	os.remove(tmpout)
	if tmperr then
		strerr = he.fget(tmperr)
		os.remove(tmperr)
	end
	if exit == "signal" then status = status + 256 end
	return succ, status, strout, strerr
end--execute()

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

	
------------------------------------------------------------------------
--[[  notes

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

local function ziplist(zipfn)
    local zl = he.shlines('unzip -ZTs '..zipfn)
    if #zl < 2 then return nil end
    local nzl = reformat_ziplines(zl)
    return nzl
end

local function zip(fn, zipfn)
    zipfn = zipfn or fn..'.zip'
--~     ret = os.execute(string.format('zip -r %s %s', zipfn, fn))
    return he.shell(string.format('zip -q -r %s %s', zipfn, fn))
end

local function unzip(zipfn, dirfn)
	-- extract in dirfn or current dir if dirfn is not specified
	dirfn = dirfn or '.'
    return he.shell(string.format('unzip -d %s %s', dirfn, zipfn))
end

local function tar(fn, zipfn)
    zipfn = zipfn or fn..'.tar'
--~     ret = os.execute(string.format('zip -r %s %s', zipfn, fn))
    return he.shell(string.format('tar cf %s %s', zipfn, fn))
end


local function tartos(fn)
    return he.shell(string.format('tar cf - %s', fn))
end



------------------------------------------------------------------------
-- find

local flist_cmd = 
	'find %s -type f -printf "%%TY%%Tm%%Td_%%TH%%TM\t%%s\t%%p\\n" '

local function findlist(dir)
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

local function findfiles(dir)
	local cmd = 'find %s -type f '
	r, status = he.shlines(strf(cmd, dir))
	if r and he.windows then r = r:map(he.pnorm) end
	return r, status
end


local function finddirs(dir)
	-- find depth-first - makes it easier to delete a file tree
	-- and can be easily sorted for a more natural order
	local cmd = 'find %s -type d -depth '
	r, status = he.shlines(strf(cmd, dir))
	if r and he.windows then r = r:map(he.pnorm) end
	return r, status
end


function test01()
	succ, status, sout, serr = execute(
		"pwd", 
		{cwd='/f/p3', stderr='yes'})
	print(succ, status)
	print("OUT", he.repr(sout))
	print("ERR", he.repr(serr))
end
	
test01()
------------------------------------------------------------------------
return {
	execute = execute,
	execute2 = execute2,
	execute3 = execute3,
	lines = lines,
	exec = exec,
	--
	zip = zip, 
	unzip = unzip, 
	ziplist = ziplist, 
	--
	findlist0 = findlist0,
	findlist = findlist,
	findfiles = findfiles,
	finddirs = finddirs,
	--
	
}
