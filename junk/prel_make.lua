

preload_fname = "hea092a.lua"
modlst = {	"he", "hefs", "hezen", "henacl", "hecsv", "heserial", 
					"hegetopt", "heexec",
}

-----------------------------------------------------------------------
he = require "hea090"

local pt = {}
local sepline = string.rep("-", 72)

for i, modname in ipairs(modlst) do
	mod = he.fget(modname .. ".lua")
	-- remove 1st line (license)
	mod = mod:gsub("^.-\n\n", "")
	mod = string.format("%s\npackage.preload.%s = function(...)\n--- module %s ---\n"
		.. "%s\n--- module end ---\nend --preload.%s\n\n",
		sepline, modname, modname, mod, modname)
	table.insert(pt, mod)
end

table.insert(pt, sepline .. "\nhe = require 'he'\nreturn he\n")
he.fput(preload_fname, table.concat(pt))

