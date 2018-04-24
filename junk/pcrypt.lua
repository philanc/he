-- pcrypt

--180423 adapt to luazen-0.10 => v0.5
--170504 added kpw command => v0.3
--170303 added pk en(de)cryption, changed op names => v0.2
--170302 initial implem.

local pcrypt_VERSION = "pcrypt 0.5"

------------------------------------------------------------------------
-- local definitions

local lz = require "luazen"

local strf = string.format

local function isin(elem, lst)
	-- test if elem is in a list
	for i,v in ipairs(lst) do if elem == v then return true end end
	return false
end
	
local function fget(fname)
	-- return content of file 'fname'
	local f, msg = io.open(fname, 'rb')
	if not f then return nil, msg end
	local s = f:read("a") ;  f:close()
	return s
end

local function fput(fname, content)
	-- write 'content' to file 'fname'
	local f = assert(io.open(fname, 'wb'))
	assert(f:write(content) ); 
	assert(f:flush()) ; f:close()
	return true
end

local function fileext(path)
	-- return path extension (or empty string if none)
	-- (this assume that path is a unix path - separator is '/')
	-- note: when a filename starts with '.' it is not considered 
	--    as an extension
	local base = path:match("^.+/(.*)$") or path
	return base:match("^.+%.(.*)$") or ""
end

local function perr(...) io.stderr:write(...); io.stderr:write("\n") end


------------------------------------------------------------------------
-- luazen-v0.10 support

lz.aead_encrypt = lz.norx_encrypt
lz.aead_decrypt = lz.norx_decrypt

lz.keypair = function()
	local ask = lz.randombytes(32)
	local apk = lz.x25519_public_key(ask)
	return apk, ask
end

function lz.key_exchange(ask, bpk)
	local sec = lz.x25519_shared_secret(ask, bpk)
	local ctx = lz.blake2b_init(32)
	lz.blake2b_update(ctx, sec)
	local k = lz.blake2b_final(ctx)
	return k
end

------------------------------------------------------------------------



local bsize = 1024 * 1024  -- use 1 MB blocks


function encrypt_stream(k, fhi, fho, pkflag)
	-- if pkflag is true, k is the public key
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
		block = fhi:read(rdlen)
		eof = (#block < rdlen)
		local cblock = lz.aead_encrypt(k, nonce, block, ninc, aad)
		ninc = ninc + 1
		fho:write(cblock)
	end--while
end--encrypt_stream()

function decrypt_stream(k, fhi, fho, pkflag)
	-- if pkflag is true, k is the secret key
	local sk, rpk
	local nonce, block 
	local aadlen
	local ninc = 0
	local eof = false
	while not eof do
		block = fhi:read(bsize)
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
		fho:write(pblock)
	end--while
	return true
end--decrypt_stream()

local function get_key32(kfn, defaultext)
	local r, msg, key, keypath
	-- try to find kfn as-is
	key = fget(kfn)
	if key then goto checkkey end
	-- try with default ext
	kfn = kfn .. defaultext
	key = fget(kfn)
	if key then goto checkkey end
	-- try to find key in ~/.config/pcrypt/
	if not kfn:find("/") then
		keypath = os.getenv"HOME" .. "/.config/pcrypt/" .. kfn
		key = fget(keypath)
	end
	if not key then return nil, "key not found" end
	
	::checkkey::
	if #key < 32 then return nil, "invalid key" end
	if #key > 32 then key = key:sub(1, 32) end
	return key
end--get_key32()

function encrypt_file(k, fni, fno, pkflag)
	local fhi, fho --file handles
	local r, msg = nil, nil
	if fni == '-' then 
		fhi = io.stdin
	else
		fhi, msg = io.open(fni)
		if not fhi then 
			msg = msg .. " (input)"
			goto close
		end
	end
	if fno == '-' then 
		fho = io.stdout
	else
		fho, msg = io.open(fno, 'w')
		if not fho then 
			msg = msg .. " (output)"
			goto close
		end
	end
	encrypt_stream(k, fhi, fho, pkflag)
	r = true
	::close::
	if fhi and fhi ~= io.stdin then assert(fhi:close()) end
	if fho and fho ~= io.stdout then assert(fho:close()) end
	return r, msg
end --encrypt_file()

function decrypt_file(k, fni, fno, pkflag)
	local fhi, fho --file handles
	local r, msg
	if fni == '-' then 
		fhi = io.stdin
	else
		fhi, msg = io.open(fni)
		if not fhi then return nil, msg .. " (input)" end
	end
	if fno == '-' then 
		return nil, "cannot decrypt to stdout."
	else
		fho, msg = io.open(fno, 'w')
		if not fho then 
			assert(fhi:close())
			return nil, msg .. " (output)" 
		end
	end
	r, msg = decrypt_stream(k, fhi, fho, pkflag)

	::close::
	if fhi and fhi ~= io.stdin then assert(fhi:close()) end
	if fho and fho ~= io.stdout then assert(fho:close()) end
	if not r then os.remove(fno); msg = "decrypt error" end
	return r, msg
end --decrypt_file()

function genkey(kfn)
	local k = lz.randombytes(32)
	return fput(kfn .. ".k", k)
end

function genkeypair(kfn)
	local pk, sk = lz.keypair()
	return fput(kfn .. ".pk", pk) and fput(kfn .. ".sk", sk)
end

function genkeypw(kfn)
	-- hack - suppress echo (unix only)
	os.execute("stty -echo")
	print("Enter password")
	local pw1 = io.read()
	print("Enter password again")
	local pw2 = io.read()
	os.execute("stty echo")
	if pw1 ~= pw2 then return nil, "entries do not match"  end
	local k = lz.argon2i(pw1, "pcrypt", 20000, 20) --pw, salt, nkb, niter
	return fput(kfn .. ".k", k)	
end

usage_str = strf([[
Usage:  
	pcrypt e   key filein fileout  - encrypt file
	pcrypt d   key filein fileout  - decrypt file
	pcrypt pke key filein fileout  - encrypt file with public key
	pcrypt pkd key filein fileout  - decrypt file with secret key

	pcrypt k   kname  - generate a key (kname.k)
	pcrypt kp  kname  - generate a pair of keys (kname.pk, kname.sk)
	pcrypt kpw kname  - generate a key (kname.k) from a password
Notes:
	key is either a keyname or a keyfile path.
	keys are also looked for in ~/.config/pcrypt/.
	"-" can be used to denote stdin or stdout.
	decryption cannot be sent to stdout.
	version: %s
		
]], pcrypt_VERSION)

function main()
	local r, msg
	local op, kfn, fni, fno, k
	local opkext = {
		e   = ".k",
		d   = ".k",
		pke = ".pk",
		pkd = ".sk",
	}
	local defaultext
	--
	op, kfn, fni, fno = arg[1], arg[2], arg[3], arg[4]
	if not (op and kfn) then goto usage end
	if isin(op, {'e', 'd', 'pke', 'pkd'}) then
		if not (kfn and fni and fno) then goto usage end
		defaultext = opkext[op]
		k, msg = get_key32(kfn, defaultext)
		if not k then perr(msg); return nil end
	end
	--
	if     op == "e"   then r, msg = encrypt_file(k, fni, fno)
	elseif op == "d"   then r, msg = decrypt_file(k, fni, fno)
	elseif op == "pke" then r, msg = encrypt_file(k, fni, fno, true)--pkflag
	elseif op == "pkd" then r, msg = decrypt_file(k, fni, fno, true)--pkflag
	elseif op == "k"   then r, msg = genkey(kfn)
	elseif op == "kp"  then r, msg = genkeypair(kfn)
	elseif op == "kpw" then r, msg = genkeypw(kfn)
	else goto usage
	end--if
	if r then
		perr(strf("pcrypt %s done.", op))
		os.exit(0)
	else
		perr(msg)
		if msg == "decrypt error" then os.exit(2) else os.exit(1) end
	end
	
	::usage::
	perr(usage_str)
	return
end

main()	


