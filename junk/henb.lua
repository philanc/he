-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[

=== henb

]]


local he = require "he"
local hezen = require "hezen"
local msock = require "msock"

------------------------------------
-- monkey patch msock
-- add msleep() for the socket-based windows impl
-- add connect
if he.windows then
	socket = require "socket"
	function msock.msleep(time_ms)
		return socket.sleep(time_ms / 1000)
	end
	function msock.connect(host, port)
		return socket.connect(host, port)
	end
end
------------------------------------

------------------------------------------------------------------------
-- local definitions


local spack, sunpack = string.pack, string.unpack
local strf = string.format

local verbose = false

local log = function(...) 
	if verbose then print(he.isodate():sub(10), ...) end
end


------------------------------------------------------------------------
-- common definitions (client and server)

local function hash(blob) 
	return he.stohex(hezen.blake2b(blob):sub(1, 32))
end

local options = {  -- default options for the server
	bindhost = "localhost",  -- server bind address
	host = "localhost",      -- server address for the client
	port = 3091,             -- server port
	exit_server = false, -- set this to true to request the server to exit
	                     -- (see serve() loop)
}

local function send(fd, code, blob)
	blob = blob or ""
	assert(code == code & 0xff) -- code must be one byte
--~ 	return msock.write(fd, spack("<Bs4", code, blob))
	msock.write(fd, spack("<BI4", code, #blob))
	if #blob > 1 then msock.write(fd, blob) end
end

local function receive(fd)
	local hd, msg, code, bln, blob
	local read = msock.bufreader(fd)
	hd, msg = read(5)
	if not hd then return nil, msg end
--~ 	print(he.stohex(hd))
	assert(#hd == 5)
	code, bln = sunpack("<BI4", hd)
	if bln > 0 then
		blob, msg = read(bln)
		if not  blob then return nil, msg end
	else
		blob = ""
	end
	return code, blob
end --receive()

local cmds = {
	NOP = 0,
	GET = 1,
	PUT = 2,
	CHK = 3,
	DEL = 4,
	--
	EXIT = 0xff
}

local status = {
	OK = 0,
	UNKNOWN = 1,
	NOTFOUND = 2,
	BADHASH = 3,
}

------------------------------------------------------------------------
-- client definitions

default_options = {
	host = "localhost",     -- server bind address
	port = 3091,            -- server port
}

local function cmd(code, blob, opt)
	-- send code, blob to server (server response is (rcode, rblob)
	-- return rblob, or nil, rcode
	opt = opt or default_options
	local fd, msg = msock.connect(opt.host, opt.port)
	if not fd then return nil, msg end
	send(fd, code, blob)
	local rcode, rblob = receive(fd)
	if rcode == 0 then
		return rblob
	else
		return nil, rcode
	end
end--cmd

local function nop(opt)
	return cmd(cmds.NOP, "", opt)
end--nop

local function exit_server(opt)
	return cmd(cmds.EXIT, "", opt)
end

local function put(blob, opt)
	local h = hash(blob)
--~ 	print('put:hash', h)
	local b, rcode = cmd(cmds.PUT, blob, opt)
	if not b then
		return nil, rcode
	elseif h ~= b then
		return nil, status.BADHASH
	end
	return h
end

local function get(bh, opt)
	-- get blob with hash bh
	local b, rcode = cmd(cmds.GET, bh, opt)
	if not b then
		return nil, rcode
	end
	local h = hash(b)	
	if h ~= bh then
		return nil, status.BADHASH
	end
	return b
end

------------------------------------------------------------------------
-- server definitions

default_server = {  
	bindhost = "localhost", -- server bind address
	host = "localhost",     -- server bind address
	port = 3091,            -- server port
	exit_server = false, -- set this to true to request the server to exit
	--
	log = log,
	--
	----------------------------
	-- server operation handlers
	-- handler sig: function(server, blob) return rcode, rblob
	[cmds.NOP] = function(server, blob) return status.OK, "" end,
	[cmds.EXIT] = function(server, blob) 
		server.log("exit requested")
		server.exit_server = true
		return status.OK, ""
	end,
	[cmds.GET] = function(server, blob)
		local rblob = he.fget(blob)
		if rblob then
			return status.OK, rblob
		else
			return status.NOTFOUND, ""
		end
	end,
	[cmds.PUT] = function(server, blob)	
		local h = hash(blob)
		he.fput(h, blob)
		return status.OK, h
	end,
	----------------------------

	} --server

local function serve(server)
	server = server or default_server
	local sso, cso -- server socket, client socket
	local msg, code, bln, blob, rcode, rblob
	local handler
	local sso = assert(msock.bind(server.bindhost, server.port))
	server.log(strf("phs: bound to %s %d", msock.getserverinfo(sso)))
	while true do
		if server.exit_server then
			msock.close(cso)
			msock.close(sso)
			return 
		end
		cso, msg = msock.accept(sso)
		if not cso then log("accept error", msg); goto continue end
		local cso_ip, cso_port = msock.getclientinfo(cso)
		server.log("serve client", cso_ip, cso_port)
		code, blob = receive(cso)
		if not code then server.log("no code"); goto close end
		handler = server[code]
		if not handler then
			send(cso, status.UNKNOWN, "") -- unknown code
		else
			rcode, rblob = handler(server, blob)
			send(cso, rcode, rblob)
		end
		::close::
		msock.close(cso)
		::continue::
	end--while
end--serve()
------------------------------------------------------------------------



------------------------------------------------------------------------
return {
	status = status,
	verbose = verbose,
	--
	-- client
	nop = nop,
	cmd = cmd,
	put = put,
	get = get,
	exit_server = exit_server,
	default_options = default_options,
	--
	-- server
	default_server = default_server,
	serve = serve,
}



