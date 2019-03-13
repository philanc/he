-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[

=== test_hebs  (hebs3 variant)


]]


local he = require "he"
local hebs3 = require "he.bs"

local dbfn = he.tmpdir() .. '/zzdb1'
local key = ('k'):rep(32)

local function test_read_write_blob()
	-- test openfile, read/writeblob, readprevblob
	os.remove(dbfn)
	he.fput(dbfn, "")
	local db, off, b, bx
	db = hebs3()
	db:openfile(dbfn, key)
	off = db:writeblob(('a'):rep(10))
--~ 	print(off)
	off = db:writeblob(('b'):rep(20))
--~ 	print(off)
	off = db:writeblob(('c'):rep(30))
--~ 	print(off)
	db:close()
	db = nil
	db = hebs3()
	db:openfile(dbfn)
	b, bx = db:readblob(10 + 12)
	assert(b == ('b'):rep(20))
	assert(bx == 54)
	b, bx = db:readprevblob()
	assert(b == ('c'):rep(30))
	assert(bx == 54)
	assert(db.endx == 96)
	db:close()

	db = nil
	db = hebs3()
	db:openfile(dbfn)
	bx = 0
	while bx < db.endx do
		b, bx = db:readblob(bx)
--~ 		print(b, bx)
	end
	assert(bx == db.endx)
	db:close()
end


test_read_write_blob()
