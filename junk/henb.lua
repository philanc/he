-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[

=== henb

]]


-- require "heap"


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
local function log(...) print(he.isodate():sub(10), ...) end

------------------------------------------------------------------------
-- common definitions (client and server)

local function hash(blob) 
	return he.stohex(hezen.blake2b(blob):sub(1, 16))
end

--~ local function read(fd, n)
--~ 	-- read n bytes from fd 
--~ 	-- return read bytes or nil, errmsg
--~ 	-- (on Windows with luasocket, fd is a socket object)
--~ 	if he.windows then
--~ 		return fd:receive(n)
--~ 	else
--~ 		return msock.read(fd, n)
--~ 	end
--~ end--read()

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
	print(he.stohex(hd))
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

local function cmd(code, blob, opt)
	-- send code, blob to server
	-- return resp blob, or true if none, or nil, code or err msg
	opt = opt or options
	local fd, msg = msock.connect(opt.host, opt.port)
	if not fd then return nil, msg end
	send(fd, code, blob)
	local rcode, rblob = receive(fd)
--~ 	print(111, respcode, respblob and #respblob)
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
	print('put:hash', h)
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

local function serverput(blob)
	local h = hash(blob)
	he.fput(h, blob)
	return status.OK, h
end

local function serverget(bh)
	local rblob = he.fget(bh)
	if rblob then
		return status.OK, rblob
	else
		return status.NOTFOUND, ""
	end
end

local function serve(opt)
	opt = opt or options
	--handler table --sig: ht[code](blob, [code]) => respcode, respblob
	local ht = opt.ht or {}
	local server, client, msg, code, bln, blob
	local rcode, rblob
	local server = assert(msock.bind(opt.bindhost, opt.port))
	log(strf("phs: bound to %s %d", msock.getserverinfo(server)))
	while true do
		if opt.exit_server then
			msock.close(client)
			msock.close(server)
			return 
		end
		client, msg = msock.accept(server)
		if not client then log("accept error", msg); goto continue end
		local vars = {} -- request variables (will be passed to the handler)
		-- log info about the client
		vars.client_ip, vars.client_port = msock.getclientinfo(client)
		log("serve client", vars.client_ip, vars.client_port)
		code, blob = receive(client)
		if not code then log("no code")
		elseif code == cmds.NOP then
			send(client, status.OK, "")
		elseif code == cmds.PUT then
			rcode, rblob = serverput(blob)
			send(client, rcode, rblob)
		elseif code == cmds.GET then
			rcode, rblob = serverget(blob)
			send(client, rcode, rblob)
		elseif code == cmds.EXIT then -- exit_server
			log("exit requested")
			opt.exit_server = true
			send(client, status.OK, "") --send ok
		else 
			send(client, status.UNKNOWN, "") -- unknown code
		end
		msock.close(client)
		::continue::
	end--while
end--serve()

return {
	options = options,
	cmds = cmds,
	status = status,
	--
	nop = nop,
	cmd = cmd,
	put = put,
	get = get,
	exit_server = exit_server,
	--
	serve = serve,
}


