-- Copyright (c) 2019  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

=== moe - morus-based encryption 

-- (here, moe is not related to anime :-)

moe functions:
encrypt()     encrypt a string; optionnally base64-encode the result
decrypt()     decrypt a string, optionnaly base64-encoded
fhencrypt()   encrypt from/to open file handles
fhdecrypt()   decrypt from/to open file handles
fileencrypt() encrypt from/to a file
filedecrypt() decrypt from/to a file
getnonce()    extract the nonce from an encrypted string
stok()        generate a key from a keyfile content
use()         select a crypto implementation or return the current one

simplified api:
sencrypt()     encrypt a string; base64-encode the result
sdecrypt()     decrypt a base64-encoded string, 

moe constants:
VERSION       moe library version
keylen        key length (in bytes)
noncelen      nonce length (in bytes)
maclen        authentication tag (MAC) length (in bytes)
cryptolib     name of the crypto library (currently "luazen" or "plc")
noncegen      name of the mechanism used to generate new nonces
              (currently "randombytes" or "/dev/urandom" or "time-based")


]]

------------------------------------------------------------------------

local spack, sunpack = string.pack, string.unpack
local byte, char = string.byte, string.char
local insert, concat = table.insert, table.concat

------------------------------------------------------------------------
local moe = {} -- the moe module table

moe.VERSION = "0.3"

moe.noncelen = 16
moe.maclen = 16
moe.keylen = 32

local encrypt -- encrypt(k, n, plain) 
local decrypt -- decrypt(k, n, encr)
local hash    -- hash(s, diglen)
local newnonce  -- return noncelen random bytes as a string
local b64encode, b64decode


function moe.use(crypto)
	-- select what crypto and psudo-random implementation to use
	-- crypto is an optional string with following values:
	--	"luazen" or "plc"
	-- if not provided, use() returns the currently selected crypto
	-- and and source used for nonces as strings
	if not crypto then return moe.cryptolib, moe.noncegen end
	local r, lz, mo, b64

	if crypto == "luazen" then
		r, lz = pcall(require, "luazen")
		if not (r and lz.morus_encrypt) then return false end
		moe.cryptolib = "luazen"
		moe.noncegen = "randombytes"
		encrypt = lz.morus_encrypt
		decrypt = lz.morus_decrypt
		hash = lz.morus_xof
		b64encode = lz.b64encode
		b64decode = lz.b64decode
		newnonce = function() 
			return lz.randombytes(moe.noncelen) 
		end
		return true
	elseif crypto == "plc" then
		r, mo = pcall(require, "plc.morus")
		if not r then return false, "plc.morus not found" end
		r, b64 = pcall(require, "plc.base64")
		if not r then return false, "plc.base64 not found" end
		moe.cryptolib = "plc"
		encrypt = mo.encrypt
		decrypt = mo.decrypt
		hash = mo.xof
		b64encode = b64.encode
		b64decode = b64.decode	
		local devrandom = io.open("/dev/urandom", "r")
		if devrandom then
			newnonce = function() 
				return devrandom:read(moe.noncelen) 
				end
			moe.noncegen = "/dev/urandom"
		else
			newnonce = function() 
				return hash(os.time()..os.clock(), moe.noncelen)
				end
			moe.noncegen = "time-based"
		end
		return true
	else
		return false, "unknown crypto"
	end
end --moe.use()

-- use luazen if it is available and built with morus, else use plc.morus
-- can be overridden by program by calling moe.use()

local r, msg = moe.use("luazen")
if not r then r, msg = moe.use("plc") end
if not r then 
	print("no available crypto.", msg)
end


-- string encryption

function moe.encrypt(k, p, armor, n)
	-- encrypt string p with key k
	-- nonce n is optional, it can be provided to obtain 
	-- a deterministic result (eg. for tests) but it is usually
	-- not provided. A random nonce is then generated.
	-- the nonce is prepended to the encrypted result
	-- if armor is true, the encrypted result is base64-encoded. 
	n = n or newnonce()
	local c = n .. encrypt(k, n, p)
	if armor then c = b64encode(c) end
	return c
end

function moe.decrypt(k, c, armor)
	-- decrypt string c. if armor, assume c is base64-encoded.
	local msg
	if armor then
		c, msg = b64decode(c)
		if not c then return nil, msg end
	end
	local n = c:sub(1, moe.noncelen)
	c = c:sub(moe.noncelen+1)
	local p
	p, msg = decrypt(k, n, c)
	if not p then return nil, msg end
	return p
end

------------------------------------------------------------------------
-- utility functions

function moe.stok(s)
	-- take a key string and generate a key ("string-to-key")
	-- (can be used for example to generate keys from a keyfile;
	-- this is _not_ a password key derivation function)
	local minlen = 1024
	-- ensure s is at least minlen bytes
	local slen = #s
	if slen < minlen then s = s:rep(math.ceil(minlen/slen)) end
	-- uniformize bits
	s = hash(s, moe.keylen)
	return s
end

function moe.getnonce(c)
	return c:sub(1, moe.noncelen)
end

------------------------------------------------------------------------
-- convenience functions / simplified API

function moe.sencrypt(ks, p)
	-- encrypt plain text p. result is armored (base64-encoded) 
	-- ks is a key string (long passphrase or 
	--   content of a keyfile, not a binary 32-byte string)
	local k = moe.stok(ks)
	return moe.encrypt(k, p, true)
end

function moe.sdecrypt(ks, c)
	-- decrypt armored encrypted text c
	-- ks is a key string (long passphrase or 
	--   content of a keyfile, not a binary 32-byte string)
	local k = moe.stok(ks)
	return moe.decrypt(k, c, true)
end

------------------------------------------------------------------------

-- file encryption

-- file encryption is performed one block at a time.

local csize = 1048576 -- encrypted block size = 1 MByte
local psize = csize - moe.noncelen - moe.maclen -- plain block size

function moe.fhencrypt(k, fhin, fhout, finlen)
	-- encrypt from and to a file handle
	-- fhin is a file handle to an open file (mode=r).
	-- fhout is a file handle to an open file (mode=w).
	-- input and output files are _not_ closed by this function.
	-- finlen is the input length (the function attempts to read
	-- up to finlen bytes). It is optional. Default is to read up to 
	-- the end of file.
	-- return the total number of bytes written to fhout, or 
	-- nil, errmsg in case of error.
	local p, c, r, msg, cnt
	local rcnt = 0 -- total read byte counter
	local wcnt = 0 -- total write byte counter
	local min = math.min
	if io.type(fhin) ~= "file" then 
		return nil, "invalid input file handle"
	end
	if io.type(fhout) ~= "file" then 
		return nil, "invalid output file handle"
	end
	finlen = finlen or math.maxinteger
	while true do
		cnt = min(psize, finlen - rcnt)
		p, msg = fhin:read(cnt)
		if not p then --eof
			return wcnt
		end
		rcnt = rcnt + #p
		c = moe.encrypt(k, p)
		r, msg = fhout:write(c)
		if not r then return nil, "output error: " .. msg end
		wcnt = wcnt + #c
	end
end --fhencrypt()

function moe.fhdecrypt(k, fhin, fhout, finlen)
	-- decrypt from and to a file handle
	-- fhin is a file handle to an open file (mode=r).
	-- fhout is a file handle to an open file (mode=w).
	-- input and output files are _not_ closed by this function.
	-- finlen is the input length (the function attempts to read
	-- up to finlen bytes). It is optional. Default is to read up to 
	-- the end of file.
	-- return the total number of bytes written to fhout, or 
	-- nil, errmsg in case of error.
	local p, c, r, msg, cnt
	local rcnt = 0 -- total read byte counter
	local wcnt = 0 -- total write byte counter
	local min = math.min
	if io.type(fhin) ~= "file" then 
		return nil, "invalid input file handle"
	end
	if io.type(fhout) ~= "file" then 
		return nil, "invalid output file handle"
	end
	finlen = finlen or math.maxinteger
	while true do
		cnt = min(csize, finlen - rcnt)
		c, msg = fhin:read(cnt)
		if not c then --eof
			return wcnt
		end
		rcnt = rcnt + #c
		p, msg = moe.decrypt(k, c)
		if not p then return nil, "decrypt error: " .. msg end
		r, msg = fhout:write(p)
		if not r then return nil, "output error: " .. msg end
		wcnt = wcnt + #p
	end
end --fhdecrypt()

function moe.fileencrypt(k, pfname, cfname)
	local pfh, cfh, r, msg
	pfh, msg = io.open(pfname)
	if not pfh then 
		return nil, "input error: " .. (msg or "") 
	end
	cfh, msg = io.open(cfname, "w")
	if not cfh then 
		pfh:close()
		return nil, "output error: " .. (msg or "") 
	end
	r, msg = moe.fhencrypt(k, pfh, cfh)
	pfh:close()
	cfh:close()
	return r, msg
end--fileencrypt

function moe.filedecrypt(k, cfname, pfname)
	local pfh, cfh, r, msg
	cfh, msg = io.open(cfname)
	if not cfh then 
		return nil, "input error: " .. (msg or "") 
	end
	pfh, msg = io.open(pfname, "w")
	if not pfh then 
		cfh:close()
		return nil, "output error: " .. (msg or "") 
	end
	r, msg = moe.fhdecrypt(k, cfh, pfh)
	pfh:close()
	cfh:close()
	if not r then
		os.remove(pfname)
	end
	return r, msg
end--filedecrypt


------------------------------------------------------------------------
return moe
