
-- Convenience definitions for interactive Lua sessions
--
--   - string functions are added to string metatable
--   - all he definitions are made global
--
-- This is not intended to be used in programs.
--

-- make he global
he = require "he"  -- make he global

-- add he string functions to string metatable
he.extend_string()

-- make all he definitions global
for k, v in pairs(he) do 
	-- do not insert a he definition if the same name already exist
	-- in the global table
	if _G[k] and (_G[k] ~= v) then 
		print("*** " .. k .. " is already defined in _G")
	else
		_G[k] = v 
	end
end

print(he.VERSION, "all he definitions are now global.")



