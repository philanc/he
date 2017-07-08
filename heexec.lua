-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

--[[ 

=== heexec module

Complement os.execute() - (poor man's popen3, popen4)

execute2  same as execute, with stdin and stdout redirected to tmp files
execute3  same as execute, with stdin, stdout and stderr redirected 
exec      convenience function (wraps execute2) 

]]
local he = require 'he'
--~ he.interactive()

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

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




------------------------------------------------------------------------
return {
	execute2 = execute2,
	execute3 = execute3,
	lines = lines,
	exec = exec,
}

