-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------


--[[

=== test_henat  -  OS native commands wrapper unit tests


]]

local he = require 'he'
local hefs = require 'he.fs'
local henat = require 'he.nat'

--~ he.interactive()

local strf = string.format
local strip = he.strip
local sep, resep = hefs.sep, hefs.resep
local win = test_windows

-- test setup
local topdir = he.tmpname('henat')

-- exit on error:    set -e 

local function gonewtmpdir(name, tmpdir)
	tmpdir = tmpdir or '/tmp'
	local dirpath = tmpdir .. '/' .. name
	local s = strf([[
		set -e 
		NAT_DIR=%s 
		rm -r -f $NAT_DIR 
		mkdir -p $NAT_DIR
		cd $NAT_DIR
		]], dirpath)
	return s
end


local filldir = [[
	mkdir d1
	echo "hello bef" > d1/bef
	echo "hello ab" > d1/ab
	



if hefs.isdir(tmp) then hefs.rmdirs(tmp) end
assert(hefs.mkdir(tmp))
hefs.pushd(tmp)
assert(hefs.mkdir('d'))
hefs.pushd('d')
he.fput('bef', 'hello bef')
he.fput('ab', 'hello ab')
hefs.popd()


--
local r, r2, rl

-- zip
r = henat.zip('d')
r = henat.zip('d', 'd2.zip')

-- ziplist
r = henat.ziplist('d.zip')
r2 = henat.ziplist('d2.zip')
--~ pp(r, #r)
assert(he.equal(r, r2))
assert(#r == 2)
assert(string.find(r[1], '8 d/ab$'))

-- unzip
assert(hefs.rmdirs(tmp .. '/d'))
r = henat.unzip('d2.zip')
--~ pp(r)
r = henat.unzip('d.zip', 'd3')
assert(hefs.fsize(he.pnorm('d/ab')) == 8)
assert(hefs.fsize(he.pnorm('d3/d/bef')) == 9)

-- findlist, findfiles, finddirs

--~ pp(henat.findlist('.'):map(he.l2s))
rl = henat.findlist('.')
-- must sort because find order different on windows...
rl:sort(function(a, b) return he.cmpany(a[3], b[3]) end)
--~ pp(rl:map(he.l2s))
--~ print(122, rl[2][2])
--~ print(123, rl[2][3])
assert(rl[2][2] == 8)
assert(rl[2][3] == "./d/ab")

rl = henat.findfiles('.')
rl:sort(he.cmpany) -- sort for windows...
assert( rl[3] == "./d/bef" )

rl = henat.finddirs('.')
assert( rl[2] == "./d3/d")

-- test exec, execute2, execute3

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

local r, msg, sin, sout, serr, e, c

-- exec

r, msg = henat.exec("lua succ.lua", "aaa")
--~ print('['..(r or "")..']', msg)
assert(r == "out:aaa")
assert(msg == nil)

r, msg = henat.exec("lua fail.lua")
--~ print('['..msg..']')
assert(r == nil)
assert(msg == "exit: 2. error message")

-- execute2

r, e, c, sout, serr = henat.execute2("lua succ.lua", "aaa")
assert(r == true and e == "exit" and c == 0)
assert(sout == "out:aaa") 

r, e, c, sout, serr = henat.execute2("lua fail.lua", "aaa")
assert(r == nil and e == "exit" and c == 2)
assert(sout == "error message") 

-- execute3

r, e, c, sout, serr = henat.execute3("lua succ.lua", "aaa")
assert(r == true and e == "exit" and c == 0)
assert(sout == "out:aaa") 
assert(serr == "")

r, e, c, sout, serr = henat.execute3("lua fail.lua", "aaa")
assert(r == nil and e == "exit" and c == 2)
assert(sout == "") 
assert(serr == "error message")

-- test cleanup
hefs.popd()
hefs.rmdirs(tmp)

