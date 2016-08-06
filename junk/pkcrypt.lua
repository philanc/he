
--[[
pkcrypt - encrypt strings and files with tweetnacl / ec25519

pkcrypt encrypts and decrypts with one keypair (the "recipient" keypair). 
  - encryption is performed with the recipient public key
  - decryption is performed with the recipient secret key

Since the nacl functions require two keypairs (one for
the sender and one for the recipient), pkcrypt generates and use a random 
keypair for each encryption. 

The random secret key is used for encryption and discarded.
The random public key is prepended to the encrypted text for decryption.
Part of the random public key is also used as a nonce.

So, with
   (ask, apk)   the random keypair ("alice")
   (bsk, bpk)   the recipient keypair ("bob")
   pt           the plain text
   et           the encrypted text
   k            the stream encryption key
   nonce        a nonce for stream encryption
   and the nacl functions,

encryption:
   apk, ask = box_keypair() -- generate the random keypair
   nonce = sub(apk, 1, 24)
   et = box(pt, nonce, bpk, ask)
   encrypted result = apk .. et

decryption:
	apk, nonce, et = split(encrypted result)
	pt = box_open(et, nonce, apk, bsk)

]]

local he = require "he"
local tw = require "tweetnacl"

local null32 = ('\0'):rep(32)
local null16 = ('\0'):rep(16)

local function easy_secretbox(pt, nonce, k)
	-- same as nacl secretbox(), but take care of the leading 32 null 
	-- bytes constraint, and remove the leading 16 null bytes in
	-- the encrypted text
	pt = null32 .. pt
	local et = tw.secretbox(pt, nonce, k)
	et = et:sub(17)
	return et
end

local function easy_secretbox_open(et, nonce, k)
	-- same as nacl secretbox_open(), but take care of the leading 
	-- 32 and 16 null bytes constraint
	et = null16 .. et -- append the leading 16 null bytes
	local pt = tw.secretbox_open(et, nonce, k)
	-- remove the leading 32 null bytes
	if pt then return pt:sub(33) else return nil, msg end
end

local function encrypt(pt, bpk)
	-- encrypt plain text pt with recipient public key bpk
	-- return  encrypted text
	local apk, ask = tw.box_keypair()
	local nonce = apk:sub(1, 24)
	local k = tw.box_beforenm(bpk, ask)
	local et = easy_secretbox(pt, nonce, k)
	return apk .. et
end

local function decrypt(et, bsk)
	-- decrypt encrypted text et with recipient secret key spk
	-- return  plain text or (nil, error msg)
	local apk = string.sub(et, 1, 32) -- 32 bytes
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	et = string.sub(et, 33) -- everything after the first 32 bytes
	local k = tw.box_beforenm(apk, bsk)
	return easy_secretbox_open(et, nonce, k)
end

local function encrypt_init(bpk)
	local apk, ask = tw.box_keypair()
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	local header = apk
	-- compute the session key used for stream encryption of blocks
	local k = tw.box_beforenm(bpk, ask)
	return header, nonce, k
end

local function encrypt_block(ptb, nonce, k)
	-- encrypt a plain text block 'ptb'
	-- update nonce for the next block
	-- return encrypted block and updated nonce
	assert(#nonce == 24, "bad nonce length")
	assert(#k == 32, "bad session key length")
	local etb = easy_secretbox(ptb, nonce, k)
	nonce = tw.sha512(nonce):sub(1,24)  -- update the nonce for next block
	return etb, nonce
end

local function decrypt_init(header, bsk)
	local apk = string.sub(header, 1, 32) -- 32 bytes
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	local k = tw.box_beforenm(apk, bsk)
	assert(#nonce == 24, "bad nonce length")
	assert(#k == 32, "bad session key length")
	return nonce, k
end

local function decrypt_block(etb, nonce, k)
	-- decrypt an encrypted block 'etb'
	-- update nonce for the next block
	-- return decrypted block and updated nonce
	local ptb, msg = easy_secretbox_open(etb, nonce, k)
	if not ptb then return nil, msg end
	nonce = tw.sha512(nonce):sub(1,24)  -- update the nonce for next block
	return ptb, nonce
end
	
--~ print(_VERSION)
bpk, bsk = tw.box_keypair()
pt = "aaa"
et = encrypt(pt, bpk)
--~ print(#pt, #et, he.repr(et))
dt, msg = decrypt(et, bsk)
assert(dt == pt)

header, nonce, k = encrypt_init(bpk)
assert(#nonce == 24, "bad nonce length")
assert(#k == 32, "bad session key length")
assert(#header == 32)
nd, kd = decrypt_init(header, bsk)
assert(nd == nonce)
assert(kd == k)
ptb = "block1"
etb, nonce2 = encrypt_block(ptb, nonce, k)
dtb, nd2 = decrypt_block(etb, nd, kd)
assert(dtb == ptb)
assert(nonce2 == nd2)

