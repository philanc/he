
-- heexec unit tests

local he = require "he"
local hefs = require 'hefs'

local heexec = require "heexec"

-- test setup
local tmp = he.ptmp('heexec')
if hefs.isdir(tmp) then hefs.rmdirs(tmp) end
assert(hefs.mkdir(tmp))
hefs.pushd(tmp)
he.fput('a', 'hello Alice')
he.fput('b', 'hello Bob')

he.fput("succ.lua", [[
	a = io.stdin:read()
	io.stdout:write('out:' .. a)
	]])
he.fput("fail.lua", [[
	io.stderr:write("error message")
	os.exit(2)
	]])

local r, r2, msg, sin, sout, serr, e, c, t, t2

-- exec

r, msg = heexec.exec("lua succ.lua", "aaa")
--~ print('['..r..']')
assert(r == "out:aaa")
assert(msg == nil)

r, msg = heexec.exec("lua fail.lua")
--~ print('['..msg..']')
assert(r == nil)
assert(msg == "exit: 2. error message")

-- execute2

r, e, c, sout, serr = heexec.execute2("lua succ.lua", "aaa")
assert(r == true and e == "exit" and c == 0)
assert(sout == "out:aaa") 

r, e, c, sout, serr = heexec.execute2("lua fail.lua", "aaa")
assert(r == nil and e == "exit" and c == 2)
assert(sout == "error message") 

-- execute3

r, e, c, sout, serr = heexec.execute3("lua succ.lua", "aaa")
assert(r == true and e == "exit" and c == 0)
assert(sout == "out:aaa") 
assert(serr == "")

r, e, c, sout, serr = heexec.execute3("lua fail.lua", "aaa")
assert(r == nil and e == "exit" and c == 2)
assert(sout == "") 
assert(serr == "error message")

-- test cleanup
hefs.popd()
hefs.rmdirs(tmp)