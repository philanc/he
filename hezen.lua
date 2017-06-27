-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file


--[[ 

hezen - complement luazen C lib

  encrypt_stream()     -- encrypt/decrypt files given open stream handles
  decrypt stream()     -- for input and output files
  
  encrypt_file()       -- encrypt/decrypt files given input, output filenames
  decrypt_file()

  lzf(), unlzf()       -- lzf-based compression

  entropy16()          -- a *very weak* random source. return a 16-byte string.
  cloak(), uncloack()  -- rc4 encryption (with a very weak IV!)
  
  b58chars  -- a string with all the base58 alphabet supported by luazen
  is_b58()             -- test if a string is a valid base58-encoded value
  
  
  170625 - added encrypt_stream() et al. (from pcrypt)
  160821 - stohex/hextos moved to he.  hexencode/hexdecode removed (redundant)
         - added is_b58(s) 
  160804 - added stohex/hextos() from plc.bin, and b58chars from plc.base58
		 
]]

local hezen = require 'luazen'

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

------------------------------------------------------------------------
-- norx encryption (from the pcrypt tool)

-- authenticated encryption for arbitrarily large files
-- encryption is performed on 'bsize'-large blocks 
-- (default: 1MB reasonably low overhead, and can be used with low memory)
-- the AE MAC is appended to each block
-- the first block is prefixed with the nonce. 
-- The nonce is incremented for each block.

-- public key encryption is supported (with a random keypair generated)
-- it allows to encrypt with only a public key and decrypt with the 
-- matching private key.
-- with pk encryption, the nonce is replaced with the random public key.
-- key exchange use the luazen.key_exchange() function
-- (curve25519 ECDH with the excahnge secret "washed" 
-- with blake2b - see luazen)


local bsize = 1024 * 1024  -- use 1 MB blocks

function hezen.encrypt_stream(k, fhi, fho, pkflag)
	-- k: a 32-byte key
	-- if pkflag is true, k is the public key
	-- fhi: file handle of an opened input file
	-- fho: file handle of an opened output file
	--
	local pk, rpk, rsk -- the public key and the random key pair
	local nonce
	if pkflag then
		pk = k
		rpk, rsk = lz.keypair()
		nonce = rpk  -- use the random pk as the nonce
		k = lz.key_exchange(rsk, pk) -- get the session key
	else
		nonce = lz.randombytes(32)
	end
	local ninc = 0
	local eof = false
	-- make sure the encrypted block is bsize bytes
	local rdlen, block, aad
	while not eof do
		-- make sure the encrypted block is bsize bytes
		if ninc == 0 then
			rdlen = bsize - 64  --32 for the nonce, 32 for the MAC
			aad = nonce  -- prefix the first block with the nonce
		else
			rdlen = bsize - 32
			aad = ""
		end
		block = assert(fhi:read(rdlen))
		eof = (#block < rdlen)
		local cblock = lz.aead_encrypt(k, nonce, block, ninc, aad)
		ninc = ninc + 1
		assert(fho:write(cblock))
	end--while
	return true
end--encrypt_stream()

function hezen.decrypt_stream(k, fhi, fho, pkflag)
	-- k: a 32-byte key
	-- if pkflag is true, k is the secret key
	-- fhi: file handle of an opened input file
	-- fho: file handle of an opened output file
	--
	-- Note: if block N decryption fails, the blocks 1,... N-1 
	-- are left decrypted in the output file which is closed.
	-- decrypted file (safe) disposal is left to the function user.
	-- (silently removing the partially decrypted file could be even
	-- worse. It would leave no opportunity to securely clean the 
	-- file - if even possible...)
	--
	local sk, rpk
	local nonce, block 
	local aadlen
	local ninc = 0
	local eof = false
	while not eof do
		block = assert(fhi:read(bsize))
		if not block then return true end --eof
		eof = (#block < bsize)
		if ninc == 0 then --first block
			nonce = block:sub(1, 32)
			if pkflag then 
				rpk = nonce -- the nonce is also the random public key
				sk = k
				k = lz.key_exchange(sk, rpk) -- get the session key
			end
			aadlen = 32
		else
			aadlen = 0
		end
		local pblock, msg = lz.aead_decrypt(k, nonce, block, ninc, aadlen)
		ninc = ninc + 1
		if not pblock then return nil, msg end
		assert(fho:write(pblock))
	end--while
	return true
end--decrypt_stream()

function hezen.encrypt_file(k, fni, fno, pkflag)
	-- convenience function
	-- fni, fno are the input, output filenames
	-- files are opened and closed by the function.
	--
	local fhi, fho, r, errmsg
	fhi, errmsg = io.open(fni, "rb")
	if not fhi then return nil, errmsg end
	fho, errmsg = io.open(fno, "wb")
	if not fho then fhi:close(); return nil, errmsg end
	r, errmsg = encrypt_stream(k, fhi, fho, pkflag)
	fhi:close()
	fho:close()
	return r, errmsg
end
	
function hezen.decrypt_file(k, fni, fno, pkflag)
	-- convenience function
	-- fni, fno are the input, output filenames
	-- files are opened and closed by the function.
	--
	local fhi, fho, r, errmsg
	fhi, errmsg = io.open(fni, "rb")
	if not fhi then return nil, errmsg end
	fho, errmsg = io.open(fno, "wb")
	if not fho then fhi:close(); return nil, errmsg end
	r, errmsg = decrypt_stream(k, fhi, fho, pkflag)
	fhi:close()
	fho:close()
	return r, errmsg
end

------------------------------------------------------------------------
-- support compression function names used by various legacy versions!

hezen.lzf = hezen.lzf or hezen.compress or hezen.zip
hezen.unlzf = hezen.unlzf or hezen.uncompress or hezen.unzip

------------------------------------------------------------------------


function hezen.entropy16(seed)
	-- return a **very weak** pseudo-random string of 16 bytes
	-- (at least, it works everywhere...)
	-- => use luazen.randombytes() instead
	return hezen.md5(tostring(seed) .. tostring(os.time() * os.clock()))
end

function hezen.cloak(s, k)
	-- encrypt string s with key k
	-- k may be a string or a number (weak!)
	-- return encrypted string
	-- note: algo is rc4. 
	--   a (bad! :-) 16-byte random iv is generated  
	--   and used to derive the key
	local iv = hezen.entropy16()
	k = hezen.md5(iv .. k)
	local e = hezen.rc4(s, k)
	return iv .. e
end

function hezen.uncloak(e, k)
	-- decrypt a string encrypted with hezen.cloak
	local iv = e:sub(1, 16)
	local e = e:sub(17)
	k = hezen.md5(iv .. k)
	local s = hezen.rc4(e, k)
	return s
end

------------------------------------------------------------------------

hezen.b58chars = 
	"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

function hezen.is_b58(s)
	-- return true if s is a valid base58-encoded string
	-- an arbitrary limit on size is also enforced 
	-- (base58 encoding should not be used for long strings)
	local pat = "^[" .. hezen.b58chars .. "]+$" -- only b58 chars
	return #s < 1024 and s:match(pat)
end

	
------------------------------------------------------------------------
return hezen

