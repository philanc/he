
local he = require "he"
local henacl = require "henacl"

local stx, xts = he.stohex, he.hextos
------------------------------------------------------------------------

assert(#henacl.randombytes(23) == 23)

-- box and secretbox functions

local pt, et, dt  -- plain text, encrypted text, decrypted text
pt = ("a"):rep(25)

-- encrypt, decrypt
local k = ("k"):rep(32)
et = henacl.encrypt(pt, k)
assert(#et == #pt + 32)
dt = henacl.decrypt(et, k)
assert(pt == dt)

-- pkencrypt, pkdecrypt
local apk, ask = henacl.box_keypair()
local bpk, bsk = henacl.box_keypair()
et = henacl.pkencrypt(pt, bpk)
assert(#et == #pt + 48)  -- header(32) + MAC(16)
dt = henacl.pkdecrypt(et, bsk)
assert(pt == dt)

-- pkencrypt, pkdecrypt with the init/block API
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

------------------------------------------------------------------------
-- print("test_luazen", "ok")
return true