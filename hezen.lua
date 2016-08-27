-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file


--[[ 

hezen - complement luazen C lib

  compress(), uncompress()  -- lzf-based compression
  entropy16()  -- a *very weak* random source. return a 16-byte string.
  cloak(), uncloack()  --  rc4 encryption (with a weak IV)
  b58chars  -- a string with all the base58 alphabet supported by luazen
  
  --
  
  160804 - added stohex/hextos() from plc.bin, and b58chars from plc.base58
  160821 - stohex/hextos moved to he.  hexencode/hexdecode removed (redundant)
         - added is_b58(s) 
		 

]]
local hezen = require 'luazen'

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat
hezen.lzf = hezen.zip or hezen.lzf or hezen.compress
hezen.unlzf = hezen.unzip or hezen.unlzf or hezen.uncompress

function hezen.entropy16(seed)
	-- return a **very weak** pseudo-random string of 16 bytes
	-- (at least, it works everywhere...)
	-- (use tweetnacl.randombytes() instead)
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

