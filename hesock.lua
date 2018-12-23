-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

=== hesock - a low level tcp socket interface

requires LuaSocket on Windows and minisock on linux

implements a socket "object" (including a buffer on linux) instead
of handling directly a file descriptor or a luasocket object.

benefits
- so is always an object (hesock class) - not a luasocket object or number.
- no more bufreader closure. the read buffer is part of the so object.


]]

------------------------------------------------------------------------
-- imports and local definitions

local he = require 'he'

local list, strf, printf, repr = he.list, string.format, he.printf, he.repr
local ssplit = he.split
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

local function repr(x)
	return strf("%q", x) 
end

local function log(...)
	print(he.isodate():sub(10), ...)
end

------------------------------------------------------------------------
-- socket interface - provided by object hesock

local hesock = he.class()

--~ if he.windows then 
if false then 
	--------------------------------------------------------------------
	-- windows / luasocket-based hesock
	
	-- minimal socket (only the core dll + bind and connect)
	-- try 'socket' first (used by current slua for win)
	local socketfound,  socket = pcall(require,  'socket')
	-- if not found, try standard name for so/dll
	if not socketfound then 
		socketfound,  socket = pcall(require,  'socket.core') 
	end
	
	-- for ipv6, just replace socket.tcp() with socket.tcp6() 
	-- in connect() and bind() below.

	function hesock.connect(address, port)
		local sock, err, r
		local sock, err = socket.tcp()
		if not sock then return nil, err end
		r, err = sock:connect(address, port)
		if not r then return nil, err end
		return hesock{ so = sock }
	end

	function hesock.bind(host, port, backlog)
		local sock, err = socket.tcp()
		if not sock then return nil, err end
		sock:setoption("reuseaddr", true)
		local res, err = sock:bind(host, port)
		if not res then return nil, err end
		res, err = sock:listen(backlog)
		if not res then return nil, err end
		return hesock{ so = sock }
	end

	function hesock.accept(so) 
		local sock, err = so.so:accept()
		if not sock then return nil, err end
		return hesock{ so = sock }
	end
	
	function hesock.getserverinfo(so) return so.so:getsockname() end
	function hesock.getclientinfo(so) return so.so:getpeername() end
	function hesock.write(so, data) return so.so:send(data) end
	function hesock.read(so, n) return so.so:receive(n) end
	function hesock.msleep(time_ms) return socket.sleep(time_ms / 1000) end
	function hesock.close(so) return so.so:close() end

else 
	--------------------------------------------------------------------
	-- linux / minisock-based hesock
	
	local minisock = require "minisock"
	
	function hesock.connect(address, port)
		local fd, err = minisock.connect(address, port)
		if not fd then return nil, err end
		return hesock{ fd = fd }
	end

	function hesock.bind(sockaddr)
		local fd, err = minisock.bind(sockaddr)
		if not fd then return nil, err end
		return hesock{ fd = fd }
	end

	function hesock.accept(so) 
		local cfd, err = minisock.accept(so.fd)
		if not cfd then return nil, err end
		return hesock{ fd = cfd }
	end

	function hesock.getserverinfo(so, numeric)
		local rawaddr, msg = minisock.getsockname(so.fd)
		if not rawaddr then return nil, msg end
		return minisock.getnameinfo(rawaddr, numeric)
	end

	function hesock.getclientinfo(so, numeric)
		local rawaddr, msg = minisock.getpeername(so.fd)
		if not rawaddr then return nil, msg end
		return minisock.getnameinfo(rawaddr, numeric)
	end

	function hesock.msleep(time_ms) return minisock.msleep(time_ms) end
	function hesock.close(so) return minisock.close(so.fd) end
	
	function hesock.write(so, s)
		return minisock.write(so.fd, s)
	end

	function hesock.read(so, n)
		-- buffered read
		-- if n then read n bytes else read a line
		-- (same as luasocket receive(n))
		so.buf = so.buf or "" -- 
		so.bi = so.bi or 1
		if not n then -- read a line
			while true do
				local i, j = so.buf:find("\r?\n", so.bi)
				if i then -- NL found. return the line
					local l = so.buf:sub(so.bi, i-1)
					so.bi = j + 1
					return l
				else -- NL not found. read more bytes into buf
					local b, msg = minisock.read(so.fd)
--~ 					print("READ", b and #b)
					if not b then return nil, msg end
					if #b == 0 then return nil, "EOF" end
					so.buf = so.buf:sub(so.bi) .. b
				end--if	
			end--while reading a line
		else -- read n bytes
			local nbs -- "n bytes string" -- expected result
			local nr -- number of bytes already read
			-- rest to read in buf:
			so.buf = so.buf:sub(so.bi)
			so.bi = 1
			nr = #so.buf -- available bytes in bt
			-- here, we have not enough bytes in buf
			local bt = { so.buf } -- collect more in table bt
			while true do
				if n <= nr then -- enough bytes in bt
					so.buf = table.concat(bt)
					nbs = so.buf:sub(1, n)
					-- keep not needed bytes in buf
					so.buf = so.buf:sub(n+1) 				
					so.bi = 1 -- start of unread bytes in buf
					return nbs
				else -- not enough, read more
					local b, msg = minisock.read(so.fd)
					if not b then return nil, msg end
					if #b == 0 then 
						--EOF, not enough bytes
						-- return what we have
						nbs = table.concat(bt)
						return nbs
					end
					nr = nr + #b
					table.insert(bt, b)
				end
			end--while reading n bytes
		end--if

	end--read()
	
end --if "windows or linux minisock"
------------------------------------------------------------------------

return hesock
