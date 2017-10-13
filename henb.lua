-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[

=== henb






]]


local he = require "he"
local hezen = require "hezen"
local hesock = require "hesock"

------------------------------------------------------------------------
-- local definitions


local spack, sunpack = string.pack, string.unpack
local strf = string.format

local log = function(...) print(he.isodate():sub(10), ...) end
local quiet = function(...) return  end



------------------------------------------------------------------------
-- common definitions (client and server)

local options = {  -- default options for the server
	bindhost = "localhost",  -- server bind address
	host = "localhost",      -- server address for the client
	port = 3091,             -- server port
	exit_server = false, -- set this to true to request the server to exit
	                     -- (see serve() loop)
}


local function hash(blob) 
	-- if hash() changes, MUST also change hashlen below.
	return he.stohex(hezen.blake2b(blob):sub(1, 32))
end

local hashlen = 64  -- MUST be equal to #hash(blob)

local function send(so, code, blob)
	blob = blob or ""
	assert(code == code & 0xff) -- code must be one byte
	return so:write(spack("<Bs4", code, blob))
end

local function receive(so)
	local hd, msg, code, bln, blob
	hd, msg = so:read(5)
	if not hd then return nil, msg end
--~ 	print(he.stohex(hd))
	assert(#hd == 5)
	code, bln = sunpack("<BI4", hd)
	if bln > 0 then
		blob, msg = so:read(bln)
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
	PUTID = 5,
	--
	EXIT = 0xff
}

local status = {
	OK = 0,
	UNKNOWN = 1,
	NOTFOUND = 2,
	BADHASH = 3,
	DELERR = 4,
	
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
	local so, msg = hesock.connect(opt.host, opt.port)
	if not so then return nil, msg end
	send(so, code, blob)
	local rcode, rblob = receive(so)
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

local function chk(bh, opt)
	-- check blob identified by bh
	-- return blob hash or nil, status.NOTFOUND
	return cmd(cmds.CHK, bh, opt)
end
	

local function del(bh, opt)
	local b, rcode = cmd(cmds.DEL, bh, opt)
	if not b then
		return nil, rcode
	end
	return true
end

local function putid(blob, bid, opt)
	-- same as put, but blob on server is not identified by its hash but 
	-- by the hash of an explicit identifier (an arbitratry name)
	-- eg. putid("some blob content", "blob_name")
	-- return the hash of the blob argument, or nil, statuscode
	local h = hash(blob)
	local hid = hash(bid)
	blob = hid .. blob
	local b, rcode = cmd(cmds.PUTID, blob, opt)
	if not b then
		return nil, rcode
	elseif h ~= b then
		return nil, status.BADHASH
	end
	return h
end

local function getid(bid, opt)
	-- get blob with hash `hash(bid)`
	-- eg.   putid("some blob content", "blob_name")
	--       blob = getid("blob_name") -- here, blob == "some blob content"
	local bh = hash(bid)
	local b, rcode = cmd(cmds.GET, bh, opt)
	if not b then
		return nil, rcode
	end
	return b
end

------------------------------------------------------------------------
-- server definitions

default_server = {  
	bindhost = "localhost", -- server bind address
	port = '3091',            -- server port
	exit_server = false,  -- set this to true to request the server to exit
	store_path = './',    -- path to dir where blobs are stored 
	                      -- (incl '/' at end)
	--
--~ 	log = log,
	log = quiet,
	--
	----------------------------
	-- storage functions
	

	sget = function(server, bname)
		return he.fget(server.store_path .. bname) 
	end, 

	sput = function(server, bname, blob)
		return he.fput(server.store_path .. bname, blob)
	end,

	sdel = function(server, bname)
		return os.remove(server.store_path .. bname)
	end,
	
	----------------------------
	-- server operation handlers
	-- handler sig: function(server, blob) return rcode, rblob
	--
	[cmds.NOP] = function(server, blob) 
		return status.OK, "" 
	end,

	[cmds.EXIT] = function(server, blob) 
		server.log("exit requested")
		server.exit_server = true
		return status.OK, ""
	end,

	[cmds.GET] = function(server, blob)
		local rblob = server.sget(server, blob)
		if rblob then
			return status.OK, rblob
		else
			return status.NOTFOUND, ""
		end
	end,

	[cmds.PUT] = function(server, blob)	
		local h = hash(blob)
		server.sput(server, h, blob)
		return status.OK, h
	end,

	[cmds.CHK] = function(server, blob)	
		local b = server.sget(server, blob)
		if not b then return status.NOTFOUND, "" end
		local h = hash(b)
		return status.OK, h
	end,

	[cmds.DEL] = function(server, blob)	
		local r, msg = server.sdel(server, blob)
		if not r then 
			server.log("del error:", msg)
			return status.DELERR, "" end
		return status.OK, ""
	end,

	[cmds.PUTID] = function(server, blob)
		local hid = blob:sub(1, hashlen)
		blob = blob:sub(hashlen + 1)
		local h = hash(blob)
		server.sput(server, hid, blob)
		return status.OK, h
	end,
	----------------------------

} --server

local function serve(server)
	server = server or default_server
	local sso, cso -- server socket, client socket
	local msg, code, bln, blob, rcode, rblob
	local handler
	local sso = assert(hesock.bind(server.bindhost, server.port))
	server.log(strf("phs: bound to %s %d", hesock.getserverinfo(sso)))
	while true do
		if server.exit_server then
			cso:close()
			sso:close()
			return 
		end
		cso, msg = sso:accept()
		if not cso then log("accept error", msg); goto continue end
		local cso_ip, cso_port = hesock.getclientinfo(cso)
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
		cso:close()
		::continue::
	end--while
end--serve()
------------------------------------------------------------------------

-- allows to run a test server with "slua henb.lua test"
-- it doesn't run when henb is required.
-- added arg[1] to allow quick syntax check within scite/F5 
-- without launching server!
-- NO! must be run in cur dir => doesnt work with require-based test!!
--~ if arg[0] == "henb.lua" and arg[1] == "test" then serve() end

------------------------------------------------------------------------
return {
	status = status,
	log = log,
	--
	-- client
	nop = nop,
	cmd = cmd,
	put = put,
	get = get,
	chk = chk,
	del = del,
	putid = putid,
	getid = getid,
	exit_server = exit_server,
	default_options = default_options,
	hash = hash,
	hashlen = hashlen,
	--
	-- server
	default_server = default_server,
	serve = serve,
}



