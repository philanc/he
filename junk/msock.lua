

--[[   

msock.lua  - a minimal Lua wrapper for the minisock C extension in slua


]]

------------------------------------------------------------------------
-- imports and local definitions


local msock = require "minisock"

-- msock additional functions

function msock.getserverinfo(fd)
	local rawaddr, msg = msock.getsockname(fd)
	if not rawaddr then return nil, msg end
	return msock.getnameinfo(rawaddr)
end

function msock.getclientinfo(fd)
	local rawaddr, msg = msock.getpeername(fd)
	if not rawaddr then return nil, msg end
	return msock.getnameinfo(rawaddr)
end

function msock.bufreader(fd)
	-- buffered read iterator over fd
	-- return a "bufread()" function 
	--    bufread()      reads a line
	--    bufread(n)     reads n bytes
	local buf, bi = "", 1
	local bt, nr = {}, 0
	return (function(n)
		if not n then -- read a line
			while true do
				local i, j = buf:find("\r?\n", bi)
				if i then -- NL found. return the line
					local l = buf:sub(bi, i-1)
--~ 					print("LL", l, #l, bi, i, j)
					bi = j + 1
					return l
				else -- NL not found. read more bytes into buf
					local b, msg = msock.read(fd)
					print("READ", b and #b)
					if not b then return nil, msg end
					if #b == 0 then return nil, "EOF" end
					buf = buf:sub(bi) .. b
				end--if	
			end--while reading a line
		else -- read n bytes
			bt = { buf:sub(bi) }
			nr = #buf
			print('N, NR', n, nr)
			while true do
				if n <= nr then -- enough bytes in bt
					--FIXME: eats more than n bytes
					-- ok for http but not general purpose...
					return table.concat(bt)
				else -- not enough, read more
					local b, msg = msock.read(fd)
					if not b then return nil, msg end
					if #b == 0 then return nil, "EOF" end
					nr = nr + #b
					table.insert(bt, b)
				end
			end--while reading n bytes
		end--if
	end)
end--bufreader


------------------------------------------------------------------------
return msock

