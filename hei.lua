
-- interactive lua

he = require "he"  -- make he global

he.interactive()

-- add some convenience functions

function ppk(t) 
	print(he.sortedkeys(t):concat(", ")) 
end

function req(name)
	local m = require(name)
	_G[name] = m
	return m
end
	
function heglob()
	for k, v in pairs(he) do 
		if _G[k] and _G[k] ~= v then 
			print(k .. " is already defined in _G")
		else
			_G[k] = v 
		end
	end
end


