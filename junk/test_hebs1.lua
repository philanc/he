-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

--[[

=== test_hebs 

]]

local he = require "he"
local hefs = require "hefs"
local heserial = require "heserial"
local hebs = require "hebs"

local dbfn = he.tmpdir() .. '/zzdb1'
local key = ('k'):rep(32)

local function test_read_write_blob()
	-- test openfile, read/writeblob, readlastblob
	os.remove(dbfn)
	he.fput(dbfn, "")
	local db, off, b
	db = hebs()
	db:openfile(dbfn, key)
	off = db:writeblob(('a'):rep(100000))
--~ 	print(off)
	off = db:writeblob(('b'):rep(200000))
--~ 	print(off)
	off = db:writeblob(('c'):rep(300000))
--~ 	print(off)
	db:close()
	db = nil
	db = hebs()
	db:openfile(dbfn, key)
	b = db:readblob(100064, 200000)
	assert(b == ('b'):rep(200000))
	b = db:readlastblob()
	assert(#b == 300000)
	db:close()
end

local function test_put_get()
	-- test open, put, get, save, list, rebuild_bloblist
	local db, b, lst
	os.remove(dbfn)
	db = assert(hebs.open(dbfn, key))
	db:put('aa', ('a'):rep(100000))
	db:put('bb', ('b'):rep(200000))
	db:put('cc', ('c'):rep(300000))
	db:save()
	db:close()
	db = nil
	db = hebs.open(dbfn, key)
	b = db:get('bb')
	assert(b == ('b'):rep(200000))
	lst = db:list()
--~ 	he.ppl(lst)
	assert(lst and lst[3][1] == "cc")
	assert(lst[2][2] == 100165 and lst[1][3] == 100000)
	db:close()
	-- test rebuild_bloblist()
	db = hebs.open(dbfn, key)
	lst = db:rebuild_bloblist()
--~ 	he.ppl(lst)
--~ 	for i, t in ipairs(lst) do
--~ 		print(t[1], he.stohex(t[2]), t[3]) -- bx, nonce, isindex
--~ 	end
	assert(#lst == 5) -- {last index, cc, bb, aa, initial empty index}
	assert(lst[1][1] == 600293)
	assert(lst[3][1] == 100165)
	assert(lst[5][1] == 0)
	assert(lst[1][3] == true) -- last index
	assert(lst[2][3] == nil)  -- 'cc' blob
	assert(lst[5][3] == true) -- initial index
	db:close()
end

test_read_write_blob()
test_put_get()

os.remove(dbfn)

--~ print'test_hebs done.'


