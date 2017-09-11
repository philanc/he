-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

--[[

=== test_henat  -  OS native commands wrapper unit tests


]]

local he = require 'he'
local hefs = require 'hefs'
local henat = require 'henat'

--~ he.interactive()

local strip = he.strip
--~ local hefs = he.fs
local sep, resep = hefs.sep, hefs.resep
local win = test_windows

-- test setup
local tmp = he.ptmp('henat')
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
--~ print(122, rl[2][2])
--~ print(123, rl[2][3])
assert(rl[2][2] == 8)
assert(rl[2][3] == "./d/ab")

rl = henat.findfiles('.')
assert( rl[3] == "./d/bef" )

rl = henat.finddirs('.')
assert( rl[2] == "./d3/d")
--

hefs.popd()
hefs.rmdirs(tmp)
