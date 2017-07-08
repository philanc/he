--[[

=== test_henacl


]]

local he = require "he"

-- a nacl C library may not be available. If not, skip the test.
if not(pcall(require, "luatweetnacl") or pcall(require, "tweetnacl")) then
	-- no tweet nacl library available (maybe a recent slua)'
	return "skipped - no nacl library available"
end

local henacl = require "henacl"

local stx, xts = he.stohex, he.hextos
------------------------------------------------------------------------

assert(#henacl.randombytes(23) == 23)

-- box and secretbox functions

local pt, et, dt  -- plain text, encrypted text, decrypted text
pt = ("a"):rep(25)

-- default key and nonce
local k = ("k"):rep(32)
local nonce = ("n"):rep(24)

-- encrypt, decrypt
--
local k = ("k"):rep(32)
et = henacl.encrypt(pt, k)
assert(#et == #pt + 24 +16) -- + nonce(24) + MAC(16)
dt = henacl.decrypt(et, k)
assert(pt == dt)

-- pkencrypt, pkdecrypt
--
local apk, ask = henacl.box_keypair()
local bpk, bsk = henacl.box_keypair()
et = henacl.pkencrypt(pt, bpk)
assert(#et == #pt + 32 + 16)  -- + header(32) + MAC(16)
dt = henacl.pkdecrypt(et, bsk)
assert(pt == dt)

-- pkencrypt, pkdecrypt with the init/block API
--
local head, nonce1, nonce2, k
head, nonce1, k = henacl.pkencrypt_init(bpk)
--~ print(#head)
et, nonce2 = henacl.pkencrypt_block(pt, nonce1, k)
assert(#nonce2 == henacl.NONCESZ and nonce2 ~= nonce1)
-- decrypt
nonce1, k = henacl.pkdecrypt_init(head, bsk)
dt, nonce2 = henacl.pkdecrypt_block(et, nonce1, k)
assert(#nonce2 == henacl.NONCESZ and nonce2 ~= nonce1)
assert(pt == dt)
-- check afternm aliases are defined
assert(henacl.box_afternm == henacl.secretbox)
assert(henacl.box_open_afternm == henacl.secretbox_open)

-- salsa20 functions
-- 
-- gen stream with arbitrary size
local s7 = henacl.stream(7, nonce, k); assert(#s7 == 7)
local s17 = henacl.stream(17, nonce, k); assert(#s17 == 17)
assert(s7 == s17:sub(1, 7))
et = henacl.stream_xor(pt, nonce, k); 
assert(#et == #pt)
dt = henacl.stream_xor(et, nonce, k); 
assert(dt == pt)

-- poly1305 / onetimeauth - test vector from rfc7539
-- 
local rfcmsg = "Cryptographic Forum Research Group"
local rfckey = he.hextos(
	"85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b")
rfcmac = he.hextos("a8061dc1305136c6c22b8baf0c0127a9")
local mac = henacl.onetimeauth(rfcmsg, rfckey)
assert(mac == rfcmac)
-- check poly1305 alias is defined
assert(henacl.poly1305 == henacl.onetimeauth) 

-- sha512 - tests vectors from section C.1, C.2 in http://
-- csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf
assert(henacl.hash == henacl.sha512)
local s, h
s = "abc"
h = he.hextos[[
  ddaf35a193617aba cc417349ae204131 12e6fa4e89a97ea2 0a9eeee64b55d39a 
  2192992a274fc1a8 36ba3c23a3feebbd 454d4423643ce80e 2a9ac94fa54ca49f
  ]]
assert(henacl.sha512(s) == h)
s = "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmn" 
  .. "hijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
h = he.hextos[[
  8e959b75dae313da 8cf4f72814fc143f 8f7779c6eb9f7fa1 7299aeadb6889018 
  501d289e4900f7e4 331b99dec4b5433a c7d329eeb6dd2654 5e96e55b874be909
  ]]
assert(henacl.sha512(s) == h)

-- signature functions (ed25519)
local msg = "Hello, Bob"
-- alice sign keypair
aspk, assk = henacl.sign_keypair()
assert(#aspk == 32 and #assk == 64)
assert(assk:sub(33) == aspk) -- the last 32 bytes of the sk are the pk
signedmsg, r = henacl.sign(msg, assk)
assert(#signedmsg == #msg + 64)
checkmsg, r = henacl.sign_open(signedmsg, aspk)
if r then print(r) end
assert(checkmsg == msg)




