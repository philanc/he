

--[[   

msockls.lua  - a minimal Lua wrapper offering the same interface 
as msock.lua but based on the standard Luasocket C extension



]]

------------------------------------------------------------------------
-- imports and local definitions

-- minimal socket (only the core dll + bind and connect)
-- try 'socket' first (used by current slua for win)
local socketfound,  socket = pcall(require,  'socket')
-- if not found, try standard name for so/dll
if not socketfound then 
	socketfound,  socket = pcall(require,  'socket.core') 
end

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

------------------------------------------------------------------------
-- msock module

msock = {}

msock.bind = socket.bind
function msock.accept(so) return so:accept() end
function msock.getserverinfo(so) return so:getsockname() end
function msock.getclientinfo(so) return so:getpeername() end
function msock.write(so, data) return so:send(data) end
function msock.bufreader(so) return function(n) return so:receive(n) end end
function msock.close(so) return so:close() end

------------------------------------------------------------------------
return msock

