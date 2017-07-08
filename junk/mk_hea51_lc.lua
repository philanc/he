
-- run with  "lua51 mk_hea51_lc.lua"



assert(_VERSION == "Lua 5.1")

-- load source 
f, msg = loadfile("hea096.lua")
print(f, msg)

-- compile, strip=true
hc = string.dump(f, true)

-- load he
f()
local he = require"he"

-- save compiled file
he.fput("hea51.lc", hc)


