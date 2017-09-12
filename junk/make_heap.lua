
-- Amalgamation. Make a 'heap<nnn>.lua' file which preloads all he* 
-- and plc.* modules. Also make a compiled version heap<nnn>.lc

preload_basename = "heap097"
src_path = "../he097/"

preload_fname = preload_basename .. ".lua"

modlst = {	
	"he", 
	"hefs", 
	"hezen", 
	"henacl", 
	"heserial", 
	"hegetopt", 
	"hecsv", 
	"henat",
	"stx",
	"msock", 
	"phs",
	--
	"test_he", 
	"test_hefs", 
	"test_hezen", 
	"test_henacl", 
	"test_heserial", 
	"test_hegetopt", 
	"test_hecsv", 
	"test_henat",
	"test_stx",
	"test_msock", 
	"test_phs",
	--
	"test_all",
	--
	"plc.aead_chacha_poly",
	"plc.base58",
	"plc.base64",
	"plc.bin",
	"plc.blake2b",
	"plc.box",
	"plc.chacha20",
	"plc.checksum",
	"plc.ec25519",
	"plc.md5",
	"plc.norx",
	"plc.norx32",
	"plc.poly1305",
	"plc.rabbit",
	"plc.rc4",
	"plc.sha2",
	"plc.sha3",
	--
}

-----------------------------------------------------------------------
-- local defs

local function fget(fname)
	-- return content of file 'fname' or nil, msg in case of error
	local f = assert(io.open(fname, 'rb'))
	local s = assert(f:read("*a"))
	f:close()
	return s
end

local function fput(fname, content)
	-- write 'content' to file 'fname'
	-- return true in case of success, or nil, msg in case of error
	local f = assert(io.open(fname, 'wb'))
	assert(f:write(content))
	assert(f:flush())
	assert(f:close())
end

-----------------------------------------------------------------------
-- make hea
local pt = {}
local sepline = string.rep("-", 72)

for i, modname in ipairs(modlst) do
	local fname = modname:gsub("plc%.", "plc//")
	local mod = fget(src_path .. fname .. ".lua")
	-- don't remove 1st line (license)
	-- mod = mod:gsub("^%-%-%s+Copyright.-\n", "")
	mod = string.format(
		"%s\npackage.preload['%s'] = function(...)\n--- module %s ---\n"
		.. "%s\n--- module end ---\nend --preload.%s\n\n",
		sepline, modname, modname, mod, modname)
	table.insert(pt, mod)
end

-- do not return he. make it global.
-- it allows to insert the hea file at the top of a lua pgm
-- No. dont return it and dont make it global.
-- each pgm should require'he' as needed.
-- table.insert(pt, sepline .. "\nhe = require 'he'\n\n")

fput(preload_fname, table.concat(pt))

------------------------------------------------------------------------
-- make compiled hea

-- load source 
f = loadfile(preload_fname)

-- compile, strip=true
hc = string.dump(f, true)

-- load he
f()
local he = require"he"

-- save compiled file
he.fput(preload_basename .. ".lc", hc)


