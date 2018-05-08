
------------------------------------------------------------------------
--[[

=== test_hebs2 

]]

local he = require "he"
local heserial = require "heserial"
local hebs2 = require "hebs2"

local dbfn = he.tmpdir() .. '/zzdb1'
local key = ('k'):rep(32)
local nn = ('n'):rep(16)

local function test_read_write_blob()
	-- test openfile, read/writeblob, readlastblob
	os.remove(dbfn)
	he.fput(dbfn, "")
	local db, off, b
	db = hebs2()
	db:openfile(dbfn, key)
	db:writeindex()
	off = db:writeblob(('a'):rep(100000), nn)
--~ 	print(off)
	off = db:writeblob(('b'):rep(200000), nn)
--~ 	print(off)
	off = db:writeblob(('c'):rep(300000), nn)
--~ 	print(off)
	db:close()
	db = nil
	db = hebs2()
	db:openfile(dbfn, key)
	b = db:readblob(db.index_size + (16 + 100000 + 16), 200000)
	assert(b == ('b'):rep(200000))
	db:close()
end

local function test_put_get()
	-- test open, put, get, save, list, rebuild_bloblist
	local db, b, lst
	os.remove(dbfn)
	assert(hebs2.create(dbfn, key, 30000))
	db = assert(hebs2.open(dbfn, key, 30000))
	db:put('aa', ('a'):rep(100000))
	db:put('bb', ('b'):rep(200000))
	db:put('cc', ('c'):rep(300000))
	db:save()
	db:close()
	db = nil
	db = hebs2.open(dbfn, key, 30000)
	b = db:get('bb')
	assert(b == ('b'):rep(200000))
	local lst = db:list()
	assert(#lst == 3)
	assert(lst[1][1] == "aa")
	assert(lst[2][2] == db.index_size + 100000 + 32)
	assert(lst[3][3] == 300000)
	db:close()
end


test_read_write_blob()
test_put_get()

os.remove(dbfn)

print'test_hebs2 done.'

