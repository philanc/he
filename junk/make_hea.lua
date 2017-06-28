

preload_basename = "hea096"
src_path = "../he096/"

preload_fname = preload_basename .. ".lua"
test_fname = "test_" .. preload_basename .. ".lua"

modlst = {	
	"he", "hefs", "hezen", 
	-- "henacl", 
	"heserial", 
	"hegetopt", 
	"hecsv", 
	"heexec",
	"hezip",
	"stx",
	"msock", "phs"
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
	mod = fget(src_path .. modname .. ".lua")
	-- remove 1st line (license)
	mod = mod:gsub("^%-%-%s+Copyright.-\n", "")
	mod = string.format(
		"%s\npackage.preload.%s = function(...)\n--- module %s ---\n"
		.. "%s\n--- module end ---\nend --preload.%s\n\n",
		sepline, modname, modname, mod, modname)
	table.insert(pt, mod)
end

-- do not return he. make it global.
-- it allows to insert the hea file at the top of a lua pgm
-- no. dont return it and dont make it global.
-- each pgm should require'he' as needed.
-- table.insert(pt, sepline .. "\nhe = require 'he'\n\n")

fput(preload_fname, table.concat(pt))

-----------------------------------------------------------------------
-- make test_hea

pt = {}

table.insert(pt, string.format("require '%s'\n\n", preload_basename))


for i, modname in ipairs(modlst) do
	mod = fget(src_path .. "test_" .. modname .. ".lua")
	-- remove 1st line (license) if any
	mod = mod:gsub("^%-%-%s+Copyright.-\n", "")
	mod = string.format(
		"%s\ndo -- test module %s \n"
		.. "%s\n"
		.. "print(string.format('test_%%-18s ok', '%s'))\n"
		.. "end -- test module %s \n\n",
		sepline, modname, mod, modname, modname)
	table.insert(pt, mod)
end

fput(test_fname, table.concat(pt))


------------------------------------------------------------------------
-- make compiled hea

-- load source 
f = loadfile(preload_basename .. ".lua")

-- compile, strip=true
hc = string.dump(f, true)

-- load he
f()
local he = require"he"

-- save compiled file
he.fput(preload_basename .. ".lc", hc)


