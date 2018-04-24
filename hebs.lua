-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

--[[

=== hebs - log-based blob storage

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
db:readlasblock([endx]) => blob, nonce, bx
db:flush()
db:readindex() => true | nil, "not an index"
db:writeindex()
db:rebuild_bloblist() => list of {bx, nonce, isindex}



]]

local he = require 'he'
local hefs = require 'hefs'
local heserial = require 'heserial'
local hezen = require 'hezen'


local spack, sunpack = string.pack, string.unpack
local insert, concat = table.insert, table.concat
local strf = string.format
local stohex = he.stohex

local function dbg() end
dbg = print

local function px(s, ln) ln = ln or 32; print(bin.stohex(s, ln)) end
local function prf(...) print(string.format(...)) end

------------------------------------------------------------------------
-- hezen monkey patch 
-- add optional args digestsize and key to blake2b()
hezen.blake2b = function(text, digsize, key)
	local ctx = hezen.blake2b_init(digsize, key)
	hezen.blake2b_update(ctx, text)
	return hezen.blake2b_final(ctx)
end

------------------------------------------------------------------------
hebs = he.class()

function hebs.openfile(db, dbname, key)
	-- open db
	local fh, msg = io.open(dbname, 'r+b')
	if not fh then return nil, msg end
	db.fh = fh
	db.key = key
	db.noncekey = hezen.blake2b(key) -- used to make nonces
	db.namet = {}   -- index { blobname => bx (blob index in file) }
	db.noncet = {}  -- index { blobhash => bx }
	db.bxt = {}     -- index { bx => bln (blob length) }
	db.changed = false
	return db
end

local function encode_nonce(db, blob)
	-- compute a 32-byte nonce for a given blob
	-- nonces _must_ be different for different blobs
	-- nonce structure:  hash(blob)[24] .. encoded_blob_length[8]
	local nonce = hezen.blake2b(blob, 24, db.noncekey)
	local code = sunpack("<I8", hezen.blake2b(nonce, 8, db.noncekey)) --uint64
	nonce = nonce .. spack("<I8", code ~ #blob) --str[32]
	return nonce
end

local function decode_nonce(db, nonce)
	-- decode the blob length and hash encoded in a nonce
	-- return the blob length 
	local coded_ln = sunpack("<I8", nonce:sub(25, 32))
	local hash = nonce:sub(1, 24)
	local code = sunpack("<I8", hezen.blake2b(hash, 8, db.noncekey))
	local ln =  code ~ coded_ln
	return ln 
end
	
function hebs.readblob(db, bx, ln)
	-- read and decrypt blob at offset bx
	-- ln is the length of the plain text blob
	-- return plain text blob and nonce (used as a unique blob identifier)
	-- raise an error in case of I/O or decrypt error
	-- encrypted blob :: blob .. MAC(32) .. trailer(32)
	-- => total length of encrypted blob in file:  eln = ln + 64
	-- trailer is the nonce.
	-- assume max eln < 2^32  (eln is encoded on 4 bytes)
	local n = db.fh:seek("set", bx)
	assert(n == bx, "offset error")
	local eln = ln + 64
	local eb = assert(db.fh:read(eln))
	assert(#eb == eln, "read error")
	local nonce = eb:sub(eln-31, eln) -- the last 32 bytes
	-- additional data:  header = none, trailer = 32 bytes (nonce)
	local b, aad, zad = hezen.norx_decrypt(db.key, nonce, eb, 0, 0, 32)
	-- if decrypt failed, b is nil and aad is the error msg
	assert(b, aad)
	return b, nonce
end --readblob()

function hebs.writeblob(db, blob, nonce)
	-- encrypt and write blob to file.
	-- nonce is optional. It is computed if not provided
	--   (keep this. it is used in put() to prevent computing nonce twice)
	-- blobs are always appended at end of file
	-- return blob offset
	-- raise an error in case of I/O error
	nonce = nonce or encode_nonce(db, blob)
	local bx = assert(db.fh:seek("end"))
	-- nonce is used as additional data trailer
	local eb = hezen.norx_encrypt(db.key, nonce, blob, 0, "", nonce)
	assert(db.fh:write(eb))
	local n = assert(db.fh:seek("end"))
	assert(n == bx + #blob + 64, "new offset error")
	return bx, nonce
end --writeblob()

function hebs.flush(db)
	return db.fh:flush()
end

function hebs.close(db)
	db.fh:flush()
	return db.fh:close()
end

function hebs.readlastblob(db, endx)
	-- get the blob ending at offset endx
	-- if endx is not provided, read last blob in file
	-- return blob and blob index in file
	if not endx then 
		endx = db.fh:seek("end")
	end
	db.fh:seek("set", endx-32)
	local nonce = db.fh:read(32)
	-- extract blob length and read blob
	local ln = decode_nonce(db, nonce)
	local bx  = endx - (ln + 64)  -- blob index	
	local b = db:readblob(bx, ln)
	return b, nonce, bx
end

function hebs.readindex(db)
	local b, nonce, bx = db:readlastblob()
	if not b:match("^@@index@@") then return nil, "not an index" end
	local idx, msg = heserial.unpack(b, 10) --start after '@@index@@'
	assert(idx, "cannot unpack index")
	db.bxt = idx.bxt
	db.namet = idx.namet
	db.noncet = idx.noncet
	return true
end

function hebs.writeindex(db)
	local idx = { bxt = db.bxt, namet = db.namet, noncet = db.noncet, }
	local bc = heserial.pack(idx)
	local b = "@@index@@" .. bc
	db:writeblob(b)
end



------------------------------------------------------------------------
-- high-level hebs API

function hebs.new(dbname, key)
	if hefs.fexists(dbname) then return nil, "file already exists" end
	he.fput(dbname, "")
	db = hebs()
	r, msg = db:openfile(dbname, key)
	if not r then return nil, msg end
	db:writeindex()
	return db
end

function hebs.open(dbname, key)
	local r, msg
	local db = hebs()
	if not hefs.fexists(dbname) then 
		he.fput(dbname, "")
		r, msg = db:openfile(dbname, key)
		if not r then return nil, msg end
		db:writeindex()
	else
		r, msg = db:openfile(dbname, key)
		if not r then return nil, msg end
	end
	r, msg = pcall(hebs.readindex, db)
	if not r then 
		print(msg)
		return nil, "cannot load index - not a valid blob file"
	end
	return db
end
	
function hebs.get(db, bname)
	-- return the blob with name 'bname' or nil, errmsg
	local bx = db.namet[bname] 
	if not bx then return nil, "unknown blob" end
	local bln = db.bxt[bx]
	local b = db:readblob(bx, bln)
	return b
end --get()

function hebs.put(db, bname, blob)
	-- if the blob already exists with the same name, nothing is changed
	-- if the blob already exists with another name, this name is added
	-- if the blob doesn't exist in db, it is added with its name.
	-- return true, or nil if nothing has changed
	local nonce = encode_nonce(db, blob)
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

function hebs.delete(db, bname)
	if not db.namet[bname] then 
		return -- nothing to do
	end
	db.namet[bname] = nil
	db.changed = true
	return true
end

		
function hebs.save(db)
	if db.changed then 
		db:writeindex()
		db:flush()
		db.changed = false
	end
end

function hebs.list(db)
	local lst = he.list()
	for i, name in ipairs(he.sortedkeys(db.namet)) do
		local bx = db.namet[name]
		local bln = db.bxt[bx]
		lst:insert(he.list{ name, bx, bln }) 
--~ 		print(bx, bln, name)
	end
	return lst
end

function hebs.rebuild_bloblist(db)
	local b, nonce, bx
	local blst = he.list()
	local bx, isindex = nil, nil
	while true do
		local isindex = nil
		b, nonce, bx = db:readlastblob(bx)
		if b:match("^@@index@@") then isindex = true end
		blst:insert{ bx, nonce, isindex }
--~ 		print(bx, stohex(nonce), isindex)
		if bx == 0 then break end
	end
	return blst
end

------------------------------------------------------------------------
return hebs


