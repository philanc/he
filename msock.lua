-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

=== msock - a low level tcp socket interface

requires LuaSocket on Windows and minisock on linux


]]

------------------------------------------------------------------------
-- imports and local definitions

local he = require 'he'
local hefs = require 'hefs'

local list, strf, printf, repr = he.list, string.format, he.printf, he.repr
local yield = coroutine.yield
local ssplit = he.split
local startswith, endswith = he.startswith, he.endswith
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

local function log(...)
	print(he.isodate():sub(10), ...)
end

------------------------------------------------------------------------
-- socket interface - provided by object msock

local msock
if he.windows then 
	--------------------------------------------------------------------
	-- windows / luasocket-based msock
	
	-- minimal socket (only the core dll + bind and connect)
	-- try 'socket' first (used by current slua for win)
	local socketfound,  socket = pcall(require,  'socket')
	-- if not found, try standard name for so/dll
	if not socketfound then 
		socketfound,  socket = pcall(require,  'socket.core') 
	end
	
	-- for ipv6, just replace socket.tcp() with socket.tcp6() 
	-- in connect() and bind() below.

	function socket.connect(address, port, laddress, lport)
		local sock, err = socket.tcp()
		if not sock then return nil, err end
		if laddress then
			local res, err = sock:bind(laddress, lport, -1)
			if not res then return nil, err end
		end
		local res, err = sock:connect(address, port)
		if not res then return nil, err end
		return sock
	end

	function socket.bind(host, port, backlog)
		local sock, err = socket.tcp()
		if not sock then return nil, err end
		sock:setoption("reuseaddr", true)
		local res, err = sock:bind(host, port)
		if not res then return nil, err end
		res, err = sock:listen(backlog)
		if not res then return nil, err end
		return sock
	end

	-- msock functions

	msock = {}
	msock.bind = socket.bind
	function msock.accept(so) return so:accept() end
	function msock.getserverinfo(so) return so:getsockname() end
	function msock.getclientinfo(so) return so:getpeername() end
	function msock.write(so, data) return so:send(data) end
	function msock.bufreader(so) return function(n) return so:receive(n) end end
	function msock.close(so) return so:close() end

else 
	--------------------------------------------------------------------
	-- linux / minisock-based msock
	
	msock = require "minisock"

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
	
end --if "windows or linux minisock"
------------------------------------------------------------------------

return msock
