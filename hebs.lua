-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

--[[

=== hebs - log-based blob storage  (hebs3 variant)

blobs are always appended at end of file.

blob is written as:  sig(4) | bloblen(4) | blob | bloblen(4)

sig and blob length are uint32 (4 bytes, little endian)
(=> blob size < 4GB)

--- low-level functions

db = hebs3()
db:openfile(filename)
db:readblob(bx) => blob      readblob starting at offset bx
db:readprevblob(ex) => blob  read blob ending at offset ex
db:writeblob(blob) => bx     append blob at end of file, return blob offset
db:flush()
db:close()


]]

local he = require 'he'

local spack, sunpack = string.pack, string.unpack
local insert, concat = table.insert, table.concat
local strf = string.format
local stohex = he.stohex

local function dbg() end
dbg = print

local function px(s, ln) ln = ln or 32; print(stohex(s, ln)) end
local function prf(...) print(string.format(...)) end

------------------------------------------------------------------------

--~ local BSIG = "\x02\x02\x02\x02"
local BSIG = 0x02020202

hebs3 = he.class()

function hebs3.openfile(db, fname)
	-- set db.fh (open file handle) and db.endx (offset at end of file)
	-- return db
	local errmsg
	db.fh, errmsg = io.open(fname, 'r+b')
	if not db.fh then return nil, errmsg end
	db.endx = db.fh:seek("end")
	return db
end

function hebs3.writeblob(db, b)
	-- blobs are always appended at end of file
	-- what is stored is BSIG | #b | b | #b
	-- where #b is blob length as 4-byte little endian
	-- return blob offset bx
	-- raise an error in case of I/O error
	assert(db.fh, "db file not open")
	local bx = db.fh:seek("end")
	db.fh:write(spack("<I4I4", BSIG, #b))
	db.fh:write(b)
	db.fh:write(spack("<I4", #b))
	local ex = db.fh:seek("end")
	assert(ex == db.endx + 12 + #b, "write error")
	db.endx = ex
	return bx
end --writeblob()
	
function hebs3.readblob(db, bx)
	-- read blob at offset bx 
	-- return blob or nil, error msg
	-- in case of I/O or signature or length error
	assert(db.fh, "db file not open")
	local x = db.fh:seek("set", bx)
	assert(x and x == bx, "seek error")
	local bprefix  = db.fh:read(8)
	assert(bprefix and #bprefix == 8, "read prefix error")
	local sig, blen = sunpack("<I4I4", bprefix)
	assert(sig == BSIG, "signature error")
	local b = db.fh:read(blen)
	assert(b and #b == blen, "read blob error")
	local suffix = db.fh:read(4)
	assert(suffix and #suffix == 4, "read suffix error")
	local blen2 = sunpack("<I4", suffix)
	assert(blen2 == blen, "suffix error")
	return b, bx + blen + 12
end --readblob()

function hebs3.readprevblob(db, ex)
	-- read blob ending at offset ex (default to end of file)
	-- return blob, blob offset or nil, error msg
	-- in case of I/O or signature or length error
	assert(db.fh, "db file not open")
	ex = ex or db.endx
	local x = db.fh:seek("set", ex-4)
	assert(x == ex - 4, "seek error")
	local suffix = db.fh:read(4)
	assert(suffix and #suffix == 4, "read suffix error")
	local blen2 = sunpack("<I4", suffix)
	x = ex - blen2 - 12
	local b, bx = db:readblob(x)
	return b, x
end --readprevblob()

function hebs3.flush(db)
	assert(db.fh, "db file not open")
	return db.fh:flush()
end

function hebs3.close(db)
	db.fh:flush()
	db.fh:close()
	db.fh = nil
	return true
end

------------------------------------------------------------------------
return hebs3

