
------------------------------------------------------------------------
--[[

=== hebs2 - log-based blob storage

--- high-level functions

new(dbname, key) => db
open(dbname, key) => db
db:get(name) => blob
db:put(name, blob) => true if db changed or nil
db:delete(name) => true if db changed or nil
db:save()
db:close()

db:list() => list of {name, bx, bln}

--- low-level functions

db:openfile(dbname, key)
db:readblob(bx, bln) => blob, nonce
db:writeblob(blob, [nonce]) => bx, nonce
db:flush()
db:readindex() => true | nil, "not an index"
db:writeindex()



]]

local he = require 'he'
local heserial = require 'heserial'
local mo = require 'plc.morus'


local spack, sunpack = string.pack, string.unpack
local insert, concat = table.insert, table.concat
local strf = string.format
local stohex = he.stohex

local function dbg() end
dbg = print

local function px(s, ln) ln = ln or 32; print(stohex(s, ln)) end
local function prf(...) print(string.format(...)) end

------------------------------------------------------------------------

local INDEX_SIZE = 20000

local hash32 = mo.hash
local encrypt = mo.encrypt
local decrypt = mo.decrypt

------------------------------------------------------------------------
hebs2 = he.class()

function hebs2.openfile(db, dbname, key, index_size)
	index_size = index_size or INDEX_SIZE
	-- open db
	local fh = assert(io.open(dbname, 'r+b'))
	db.fh = fh
	db.index_size = index_size
	db.key = key
	db.noncekey = hash32(key)
	db.noncetime = os.time()
	db.nonceclk = os.clock()
	db.noncectr = 1
	db.namet = {}   -- index { blobname => bx (blob index in file) }
	db.noncet = {}  -- index { blobhash => bx }
	db.bxt = {}     -- index { bx => bln (blob length) }
	db.changed = false
	return db
end

function hebs2.hashblob(db, b)
	-- compute the hash of a blob
	local dig = hash32(b, 32, db.noncekey)
	return dig
end
	
function hebs2.readblob(db, bx, ln)
	-- read and decrypt blob at offset bx 
	-- ln is the length of the plain text blob
	-- so eln,  the length of the encrypted blob, 
	-- is 16 + ln + 16 (iv, e, mac)
	-- return plain text blob or nil, error msg
	-- in case of I/O or decrypt error
	assert(bx == db.fh:seek("set", bx), "seek error")
	local eln = ln + 32  -- 16-byte nonce, 16-byte mac
	local eb = assert(db.fh:read(eln), "read error")
	local nonce = eb:sub(1, 16) -- the first  bytes
	-- additional data:  prefix = 16 bytes (nonce)
	local b = assert(decrypt(db.key, nonce, eb, 16))
	return b
end --readblob()

function hebs2.writeblob(db, blob, nonce)
	-- encrypt and write blob to file.
	-- blobs are writtenare always appended at end of file
	-- return blob offset
	-- raise an error in case of I/O error
	assert(#nonce == 16)
	local eb = encrypt(db.key, nonce, blob, nonce)
	local bx = assert(db.fh:seek("end"), "seek error")
	assert(db.fh:write(eb), "write error")
	return bx
end --writeblob()

function hebs2.flush(db)
	return db.fh:flush()
end

function hebs2.close(db)
	db.fh:flush()
	return db.fh:close()
end

function hebs2.readindex(db)
	local b = db:readblob(0, db.index_size-32)
	local idx = heserial.unpack(b)
	assert(idx, "cannot unpack index")
	assert(not idx.next, "index extension not supported")
	db.bxt = idx.bxt
	db.namet = idx.namet
	db.noncet = idx.noncet
	return true
end

function hebs2.writeindex(db)
	local idx = { bxt = db.bxt, namet = db.namet, noncet = db.noncet, }
	local b = heserial.pack(idx)
	assert(#b < db.index_size, "index extension not supported")
	b = b .. ('\0'):rep(db.index_size - 32 - #b)
	local nonce = db:hashblob(b):sub(1, 16)
	local eb = encrypt(db.key, nonce, b, nonce)
	-- write index at offset 0
	local bx = assert(db.fh:seek("set"), "seek error")
	assert(db.fh:write(eb), "write error")
end

------------------------------------------------------------------------
-- high-level hebs2 API

function hebs2.create(dbname, key, index_size)
	index_size = index_size or INDEX_SIZE
	local fh, msg = io.open(dbname)
	if fh then 
		fh:close()
		return nil, "file already exists"
	end
	he.fput(dbname, "")
	db = hebs2()
	db:openfile(dbname, key, index_size)
	db:writeindex()
	db:close()
	return true
end

function hebs2.open(dbname, key, index_size)
	index_size = index_size or INDEX_SIZE
	local r, msg
	local db = hebs2()
	db:openfile(dbname, key, index_size)
	db:readindex()
	return db
end
	
function hebs2.get(db, bname)
	-- return the blob with name 'bname' or nil, errmsg
	local bx = db.namet[bname] 
	if not bx then return nil, "unknown blob" end
	local bln = db.bxt[bx]
	local b = db:readblob(bx, bln)
	return b
end --get()

function hebs2.put(db, bname, blob)
	-- if the blob already exists with the same name, nothing is changed
	-- if the blob already exists with another name, this name is added
	-- if the blob doesn't exist in db, it is added with its name.
	-- return true, or nil if nothing has changed
	local dig = db:hashblob(blob)
	local nonce = dig:sub(1, 16)
	local bx, bln = 0, #blob
	local bxh, bxn = db.noncet[nonce], db.namet[bname]
	if bxh then -- a blob with this hash exists
		if bxn and bxh == bxn then 
			-- same blob with same name
			-- nothing to do
--~ 			dbg('already in db:', bname)
			return nil
		else
			-- new name for an existing blob
			db.namet[bname] = bxh
			db.changed = true
		end
	else -- no blob with this hash
		bx = db:writeblob(blob, nonce)
		db.noncet[nonce] = bx
		db.namet[bname] = bx
		db.bxt[bx] = bln
		db.changed = true
	end
	return true
end --put()

function hebs2.delete(db, bname)
	if not db.namet[bname] then 
		return -- nothing to do
	end
	db.namet[bname] = nil
	db.changed = true
	return true
end

		
function hebs2.save(db)
	if db.changed then 
		db:writeindex()
		db:flush()
		db.changed = false
	end
end

function hebs2.list(db)
	local lst = he.list()
	for i, name in ipairs(he.sortedkeys(db.namet)) do
		local bx = db.namet[name]
		local bln = db.bxt[bx]
		lst:insert(he.list{ name, bx, bln }) 
--~ 		print(bx, bln, name)
	end
	return lst
end

------------------------------------------------------------------------
return hebs2

