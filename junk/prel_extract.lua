
he = require "hea090"


local preload_fname = "hea095.lua"
local preload = he.fget(preload_fname)

lic = "-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file\n\n"
--~ 	.. ("-"):rep(72) .. "\n"


local i, j, ie, je, modname, mod
j = 1
while true do
	i, j, modname = preload:find("\n%-%-%-%s+module%s+(%S+)%s+%-%-%-%s+", j)
	if not i then break end
	print(i,j,modname)
	ie, je = preload:find("\n%-%-%-%s+module end%s+%-%-%-%s+", j)
	if not ie then
		he.printf("module %s not well formed. '--- module end ---' missing", modname)
		break
	end
	mod = preload:sub(j, ie)
	mod = lic .. he.dos2unix(mod)
	he.fput(modname .. ".lua", mod)
	j = je
end