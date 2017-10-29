-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[

=== henb  v0.2

171029  v0.2
- simplification of the public interface
- remove hash-based identification of blobs

Client API:  ('opt' is "optional server options")

get(bid, opt)  => blob or nil, err
	return the blob associated with bid

put(bid, blob, opt)  => ok or nil, err  
	store a blob on server with name bid
	fail if blob bid already exists

uddate(bid, blob, opt)  => ok or nil, err  
	store a blob on server with name bid
	if blob bid already exists, the blob is replaced.

del(bid, opt) => => ok or nil, err
	delete blob with name bid

nop(opt) => ok or nil, err  
	do nothing (can be used to ping server)

Server API:

serve(server)




]]

local VERSION = "0.2"


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

local function send(so, code, id, content)
	content = content or ""
	id = id or ""
	assert(code == code & 0xff, "code must be one byte")
	assert(#id <= 0xff, "id ln must be one byte")
	local data = spack("<BBI4", code, #id, #content) -- 6 bytes
	if id ~= "" then data = data .. id end
	if content ~= "" then data = data .. content end
	return so:write(data)
end

local function receive(so)
	local hd, msg, code, idln, id, bln, blob
	hd, msg = so:read(6)
	if not hd then return nil, msg end
--~ 	print(he.stohex(hd))
	assert(#hd == 6)
	code, idln, bln = sunpack("<BBI4", hd)
	if idln > 0 then
		id, msg = so:read(idln)
		if not  id then return nil, 'read_id: ' .. msg end
	else
		id = ""
	end
	if bln > 0 then
		blob, msg = so:read(bln)
		if not  blob then return nil, 'read_blob: ' .. msg end
	else
		blob = ""
	end
	return code, id, blob
end --receive()

local cmds = {
	NOP = 0,
	GET = 1,
	PUT = 2,
	UPD = 3,
	DEL = 4,
	CHK = 5,
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

local function cmd(code, id, blob, opt)
	-- send code, blob to server (server response is (rcode, rblob)
	-- (id is not used in server responses)
	-- return rblob, or nil, rcode
	opt = opt or default_options
	local so, msg = hesock.connect(opt.host, opt.port)
	if not so then return nil, msg end
	send(so, code, id, blob)
	local rcode, id, rblob = receive(so)
	hesock.close(so)
	if rcode == 0 then
		return rblob
	else
		return nil, rcode
	end
end--cmd

local function nop(opt)
	return cmd(cmds.NOP, "",  "", opt)
end--nop

local function exit_server(opt)
	return cmd(cmds.EXIT, "", "", opt)
end

local function put(bid, blob, opt)
	return cmd(cmds.PUT, bid, blob, opt)
end

local function update(bid, blob, opt)
	return cmd(cmds.UPD, bid, blob, opt)
end

local function get(bid, opt)
	-- get blob with id 'bid'
	return cmd(cmds.GET, bid, "", opt)
end

local function chk(bid, opt)
	-- check blob identified by bid
	-- return blob ln or nil, status.NOTFOUND
	local rblob, rcode = cmd(cmds.CHK, bid, "", opt)
	if not rblob then return nil, rcode end
	local bln, msg = sunpack("<I4", rblob)
	return bln, msg
end

local function del(bh, opt)
	return cmd(cmds.DEL, bh, opt)
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
	-- handler sig: function(server, id, blob) return rcode, rblob
	--
	[cmds.NOP] = function(server, id, blob) 
		return status.OK, "" 
	end,

	[cmds.EXIT] = function(server, id, blob) 
		server.log("exit requested")
		server.exit_server = true
		return status.OK, ""
	end,

	[cmds.GET] = function(server, id, blob)
		local rblob = server.sget(server, id)
		if rblob then
			return status.OK, rblob
		else
			return status.NOTFOUND, ""
		end
	end,

	[cmds.PUT] = function(server, id, blob)	
		server.sput(server, id, blob)
		return status.OK, ""
	end,

	[cmds.CHK] = function(server, id, blob)	
		local b = server.sget(server, id)
		if not b then return status.NOTFOUND, "" end
		return status.OK, spack("<I4", #b)
	end,

	[cmds.DEL] = function(server, id, blob)	
		local r, msg = server.sdel(server, id)
		if not r then 
			server.log("del error:", msg)
			return status.DELERR, "" end
		return status.OK, ""
	end,
	----------------------------

} --server

local function serve(server)
	server = server or default_server
	local sso, cso -- server socket, client socket
	local msg, code, idln, id, bln, blob, rcode, rblob
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
		code, id, blob = receive(cso)
		if not code then server.log("no code"); goto close end
		handler = server[code]
		if not handler then
			send(cso, status.UNKNOWN, "") -- unknown code
		else
--~ server.log("request code, id, bln: ", code, he.repr(id), #blob)
			rcode, rblob = handler(server, id, blob)
--~ server.log("response rcode, rblob: ", rcode, he.repr(rblob))
			send(cso, rcode, "", rblob)
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
	VERSION = VERSION,
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
	exit_server = exit_server,
	default_options = default_options,
	--
	-- server
	default_server = default_server,
	serve = serve,
}



