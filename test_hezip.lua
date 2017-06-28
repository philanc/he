-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

-- test_hezip -  zip wrapper unit tests

local he = require 'he'
local hefs = require 'hefs'
local hezip = require 'hezip'

local strip = he.strip
--~ local hefs = he.fs
local sep, resep = hefs.sep, hefs.resep
local win = test_windows

-- test setup
local tmp = he.ptmp('hezip')
if hefs.isdir(tmp) then hefs.rmdirs(tmp) end
assert(hefs.mkdir(tmp))
hefs.pushd(tmp)
assert(hefs.mkdir('d'))
hefs.pushd('d')
he.fput('bef', 'hello bef')
he.fput('ab', 'hello ab')
hefs.popd()

--
local r, r2

-- zip
r = hezip.zip('d')
r = hezip.zip('d', 'd2.zip')

-- ziplist
r = hezip.ziplist('d.zip')
r2 = hezip.ziplist('d2.zip')
--~ pp(r, #r)
assert(he.equal(r, r2))
assert(#r == 2)
assert(string.find(r[1], '8 d/ab$'))

-- unzip
assert(hefs.rmdirs(tmp .. '/d'))
r = hezip.unzip('d2.zip')
--~ pp(r)
r = hezip.unzip('d.zip', 'd3')
assert(hefs.fsize(he.pnorm('d/ab')) == 8)
assert(hefs.fsize(he.pnorm('d3/d/bef')) == 9)
--

hefs.popd()
hefs.rmdirs(tmp)
