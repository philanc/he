

preload_fname = "hea095.lua"

modlst = {	
	"he", "hefs", "hezen", 
	-- "henacl", 
	"hecsv", "heserial", 
	"hegetopt", "heexec",
	"stx",
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

local pt = {}
local sepline = string.rep("-", 72)

for i, modname in ipairs(modlst) do
	mod = fget(modname .. ".lua")
	-- remove 1st line (license)
	mod = mod:gsub("^.-\n\n", "")
	mod = string.format(
		"%s\npackage.preload.%s = function(...)\n--- module %s ---\n"
		.. "%s\n--- module end ---\nend --preload.%s\n\n",
		sepline, modname, modname, mod, modname)
	table.insert(pt, mod)
end

-- do not return he. make it global.
-- it allows to insert the hea file at the top of a lua pgm
table.insert(pt, sepline .. "\nhe = require 'he'\n\n")

fput(preload_fname, table.concat(pt))

