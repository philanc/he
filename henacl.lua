-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file


--[[ 

henacl - complement tweetnacl C lib

-- some constants

KEYSZ = 32
NONCESZ = 24

-- secret key authenticated encryption (salsa20+poly1305) 
-- it wraps secretbox()

encrypt              encrypt a text 
decrypt              decrypt a text encrypted with encrypt()

-- public key encryption (curve25519)
-- it wraps box()

pkencrypt            encrypt a text with a public key
pkdecrypt            decrypt the text with the corresponding secret key

pkencrypt_init     | allow to encrypt several blocks 
pkencrypt_block    | with the same session key

pkdecrypt_init     | allow to decrypt several blocks 
pkdecrypt_block    | with the same session key  
			       | (encrypted with pkencrypt_init/pkencrypt_block)



]]

local he = require "he"
local henacl = require "luatweetnacl"

-- key and nonce sizes
henacl.KEYSZ = 32
henacl.NONCESZ = 24

function henacl.encrypt(pt, k)
	-- wraps nacl secretbox. takes care of nonce 
	-- generates a 24-byte random nonce 
	local nonce = henacl.randombytes(24)
	local et = henacl.secretbox(pt, nonce, k)
	et = nonce .. et
	return et
end

function henacl.decrypt(et, k)
	-- decrypt a text encrypted with nacl.encrypt
	-- wraps nacl secretbox_open. takes care of nonce.
	local nonce = et:sub(1, 24)
	et = et:sub(25)
	local pt, msg = henacl.secretbox_open(et, nonce, k)
	return pt, msg
end

function henacl.pkencrypt(pt, bpk)
	-- encrypt plain text pt with recipient public key bpk
	-- return  encrypted text
	local apk, ask = henacl.box_keypair()
	local nonce = apk:sub(1, 24)
	local k = henacl.box_beforenm(bpk, ask)
	local et = henacl.secretbox(pt, nonce, k)
	return apk .. et
end

function henacl.pkdecrypt(et, bsk)
	-- decrypt encrypted text et with recipient secret key spk
	-- return  plain text or (nil, error msg)
	local apk = string.sub(et, 1, 32) -- 32 bytes
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	et = string.sub(et, 33) -- everything after the first 32 bytes
	local k = henacl.box_beforenm(apk, bsk)
	return henacl.secretbox_open(et, nonce, k)
end

function henacl.pkencrypt_init(bpk)
	local apk, ask = henacl.box_keypair()
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	local header = apk
	-- compute the session key used for stream encryption of blocks
	local k = henacl.box_beforenm(bpk, ask)
	return header, nonce, k
end

function henacl.pkencrypt_block(ptb, nonce, k)
	-- encrypt a plain text block 'ptb'
	-- update nonce for the next block
	-- return encrypted block and updated nonce
	assert(#nonce == 24, "bad nonce length")
	assert(#k == 32, "bad session key length")
	local etb = henacl.secretbox(ptb, nonce, k)
	nonce = henacl.sha512(nonce):sub(1,24) -- update the nonce for next block
	return etb, nonce
end

function henacl.pkdecrypt_init(header, bsk)
	local apk = string.sub(header, 1, 32) -- 32 bytes
	local nonce = string.sub(apk, 1, 24) -- 24 bytes
	local k = henacl.box_beforenm(apk, bsk)
	assert(#nonce == 24, "bad nonce length")
	assert(#k == 32, "bad session key length")
	return nonce, k
end

function henacl.pkdecrypt_block(etb, nonce, k)
	-- decrypt an encrypted block 'etb'
	-- update nonce for the next block
	-- return decrypted block and updated nonce
	local ptb, msg = henacl.secretbox_open(etb, nonce, k)
	if not ptb then return nil, msg end
	nonce = henacl.sha512(nonce):sub(1,24) -- update the nonce for next block
	return ptb, nonce
end

------------------------------------------------------------------------
return henacl

