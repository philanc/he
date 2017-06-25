
local he = require 'he'
local hefs = require 'hefs'
local heserial = require 'heserial'
local hezen = require 'hezen'


local spack, sunpack = string.pack, string.unpack
local insert, concat = table.insert, table.concat
local strf = string.format

local stohex = he.stohex

local function px(s, ln) ln = ln or 32; print(bin.stohex(s, ln)) end
local function prf(...) print(string.format(...)) end

------------------------------------------------------------------------

blockstorage = he.class()

function blockstorage.open(db, dbname, key)
	-- open db
	local fh, msg = io.open(dbname, 'a+b')
	if not fh then return nil, msg end
	db.fh = fh
	db.key = key
	db.seed = hezen.randombytes(24) -- used to build the nonces
	db.sig = 0x02020202
	db.index = {}
	db.changed = false
	return db
end

function blockstorage.readblock(db, offset, ln)
	-- return block at offset (ln is the length of the decrypted block)
	-- raise an error in case of I/O or decrypt error
	-- encrypted block :: header(32 bytes) .. block .. MAC(32) .. trailer(4)
	-- => total length of encrypted block in file:  eln = ln + 68
	-- assume max eln < 2^32  (eln is encoded on 4 bytes)
	-- header structure:  sig(4) .. eln(4) .. random(24)
	-- header tsructure:  eln(4)
	local n = db.fh:seek("set", offset)
	assert(n == offset, "offset error")
	local eln = ln + 68
	local eb = assert(db.fh:read(eln))
	assert(#eb == eln, "read error")
	local nonce = eb:sub(1, 32)
	-- additional data:  header = 32 bytes (nonce), trailer = 4 bytes (eln)
	local b, aad, zad = hezen.aead_decrypt(db.key, nonce, eb, 0, 32, 4)
	-- if decrypt failed, b is nil and aad is the error msg
	assert(b, aad)
	return b
end --readblock()

function blockstorage.writeblock(db, block)
	-- return block offset
	-- raise an error in case of I/O error
	-- assume blocks are always appended at end of file
	-- (=> the last 4 bytes are the length of the last encrypted block)
	local offset = assert(db.fh:seek("end"))
	local eln = #block + 68
	local nonce = spack("<I4I4", db.sig, eln) .. db.seed  -- #nonce == 32
	local trailer = spack("<I4", eln) -- #trailer == 4
	-- nonce is used also as additional data prefix
	local eb = assert(
		hezen.aead_encrypt(db.key, nonce, block, 0, nonce, trailer))
	-- refresh the db nonce base:
	db.seed = hezen.blake2b(nonce):sub(1,24) -- renew the nonce seed
	assert(db.fh:write(eb))
	local n = assert(db.fh:seek("end"))
	assert(n == offset + eln, "new offset error")
	return offset
end --writeblock()

function blockstorage.flush(db)
	return db.fh:flush()
end

function blockstorage.close(db)
	db.fh:flush()
	return db.fh:close()
end

function blockstorage.readlastblock(db)
	local n = assert(db.fh:seek("end"))
	assert(db.fh:seek("set", n-4))
	local x = db.fh:read(4)
	local lbln = sunpack("<I4", x)
	local b = db:readblock(n - lbln, lbln - 68)
	return b
end

function blockstorage.unpackblock(b)
	local bc, bname, battr = sunpack("<s4s2s2", b)
	return bc, bname, battr
end

function blockstorage.unpackcontent(b)
	return  sunpack("<s4", b)
end

function blockstorage.packblock(bc, bname, battr)
	return spack("<s4s2s2", bc, bname, battr or "")
end

function blockstorage.readindex(db)
	local b = db:readlastblock()
	local bc, bname = blockstorage.unpackblock(b)
	if bname ~= "*index*" then return nil, "not an index" end
	local idx, msg = heserial.deserialize(bc)
	assert(idx, "cannot deserialize index")
	db.index = idx
	return true
end

function blockstorage.writeindex(db)
	local bc = heserial.serialize(db.index)
	local b = blockstorage.packblock(bc, "*index*")
	db:writeblock(b)
end

function blockstorage.get(db, bname)
	local ba = db.index[bname] 
	if not ba then return nil, "unknown block" end
	local b = db:readblock(ba.offset, ba.ln)
	local bc = blockstorage.unpackcontent(b)
	return bc, ba.battr
end

function blockstorage.put(db, bname, bcontent, battr)
	local ba = db.index[bname] 
	if not ba then 
		db.index[bname] = {}
		ba = db.index[bname] 
	end
	battr = battr or ""
	ba.battr = battr
	local b = blockstorage.packblock(bcontent, bname, battr)
	local offset = db:writeblock(b)
	db.changed = true
	ba.offset = offset
	ba.ln = #b
--~ 	ba.dummy = "hello"
--~ 	he.ppt(ba)
	return true
end

function blockstorage.save(db)
	db:writeindex()
	db:flush()
	db.changed = false
end


------------------------------------------------------------------------
--~ return blockstorage


------------------------------------------------------------------------
-- smoketest

function test_read_writeblock()
	os.remove('zzd')
	db = blockstorage()
	key = ('k'):rep(32)
	db:open('zzd', key)
	--~ print(db:writeblock("bbbbb"))
	--~ print(db:writeblock("ccc"))
	off = db:writeblock(('a'):rep(100000))
	print(off)
	off = db:writeblock(('b'):rep(200000))
	print(off)
	off = db:writeblock(('c'):rep(300000))
	print(off)
	db:close()
	db = nil
	db = blockstorage()
	db:open('zzd', key)
	b = db:readblock(100068, 200000)
	assert(b == ('b'):rep(200000))
	b = db:readlastblock()
	assert(#b == 300000)
	db:close()
end

function test_put_get()
	os.remove('zzd')
	db = blockstorage()
	key = ('k'):rep(32)
	db:open('zzd', key)
	db:put('aa', ('a'):rep(100000))
	db:put('bb', ('b'):rep(200000))
	db:put('cc', ('c'):rep(300000))
	db:writeindex()
	db:close()
	db = nil
	db = blockstorage()
	db:open('zzd', key)
	db:readindex()
	b = db:get('bb')
	assert(b == ('b'):rep(200000))
--~ 	he.pp(db.index)
--~ 	he.pp(db.index.bb)
	db:close()
end

function test_arc()
	os.remove('zza')
	db = blockstorage()
	key = ('k'):rep(32)
	db:open('zza', key)
	for i, fn in ipairs(hefs.findfiles("/ut/lib/scite05")) do
		local fc = he.fget(fn)
		db:put(fn, fc)
	end
	db:writeindex()
	db:close()
	db = nil	
	db = blockstorage()
	db:open('zza', key)
	db:readindex()
	skt = he.sortedkeys(db.index)
	for i, k in ipairs(skt) do
		local bc = db:get(k)
		print(k, #bc)
	end
end--test_arc()

--~ test_read_writeblock()
--~ test_put_get()

test_arc()

