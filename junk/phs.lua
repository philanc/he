-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

phs - a tiny HTTP server


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



------------------------------------------------------------------------
-- HTTP SERVER 
------------------------------------------------------------------------

-- phs, the root server object

phs = {
	-- default configuration
	port = '3090',
	-- bind_address = '*', -- for access from other hosts
	bind_address = 'localhost', -- for local access only 
	-- bind_address = '::1',    -- for ip6 localhost

	wwwroot = '.', -- serve from the current directory
	rootdefault = '/index.html',
	-- server state
	version = 'phs.03',
	must_exit = false,
	must_reload = false,
	debug_mode = true,
	log = log,
}

-- the server main loop
	
function phs.serve()
	-- server main loop:
	-- 	wait for a client
	--	call serve_client() to process client request
	--	rinse, repeat
	local client, msg
	local server = assert(msock.bind(phs.bind_address, phs.port))
	log(strf("phs: bound to %s %d", msock.getserverinfo(server)))
	while true do
		if phs.must_exit or phs.must_reload then 
			if client then msock.close(client); client = nil end
			local r, msg = msock.close(server)
			print("Server close:", r, msg)
			os.exit(phs.must_exit and 1 or 0)
		end
		client, msg = msock.accept(server)
		if not client then
			log("phs.serve(): accept() error", msg)
		elseif phs.debug_mode then 
--~ 			log("serving client", client)
			phs.serve_client(client) -- serve and close the connection
--~ 			log("client closed.", client)
		else
			pcall(phs.serve_client, client)
		end
	end--while
end--server()


------------------------------------------------------------------------
-- serve client utilities -- receive request, headers, send response

local function receive_request(bufread, vars)
	-- get request first line
	-- beware firefox "speculative connection" when hovering links!
	--     => client will open connections and not send any request... 
	local req, errmsg = bufread()
	if not req then return nil, errmsg end
	local op, path = string.match(req, '(%a+)%s+(%S+)%s+(%S+)')
	if not op then -- ignore silently
		log("badrequest", req)
		msock.close(client)
		return nil, "bad request"
	end
	vars.op = op:upper()
	vars.reqpath = path
	vars.req = req
	log(op, path)
	return req
end--receive_request

local function receive_headers(bufread, vars)
-- process headers from a connection (borrowed from orbiter/luasocket)
-- return headers table {headername=headervalue, ...} and remaining
-- unread content of the read buffer if any
-- note that the variables names are uppercased and have '-' replaced 
-- with '_' to make them WSAPI compatible (e.g. HTTP_CONTENT_LENGTH)
	local line, name, value, err
	-- get first line
	line = assert(bufread(), "receiving header 1st line")
	while line ~= "" do  -- headers go until a blank line is found
--~ 		print('=', line)
		-- get field-name and value
		name, value = line:match "^(.-):%s*(.*)"
		assert(name and value, "malformed reponse headers")
		name = 'HTTP_'..name:upper():gsub('%-','_')
		-- get next line (value may be folded)
		line = bufread()
		if not line then error(err .. " (receiving header line)") end
		-- unfold any folded values
		while line:find("^[ \t]") do
			value = value .. line
			line = assert(bufread(), "receiving header continuation line")
		end
		-- save pair in table, concat values for existing names
		if vars[name] then 
			vars[name] = vars[name] .. ", " .. value
		else 
			vars[name] = value 
		end
	end
	return vars
end--receive_headers()

-- send response

local status_codes = {
	[200] = "200 Ok",
	[301] = "301 Moved Permanently",
	[302] = "302 Found",
	[303] = "303 See Other",
	[304] = "304 Not Modified",
	[307] = "307 Temporary Redirect",
	[400] = "400 Bad Request",
	[401] = "401 Unauthorized",
	[403] = "403 Forbidden",
	[404] = "404 Not Found",
	[405] = "405 Method Not Allowed",
	[410] = "410 Gone",
	[500] = "500 Internal Server Error",
	[501] = "501 Not Implemented",
}

local function get_status(code)
	return status_codes[code] or tostring(code)
end

local function get_statusline(status)
	if type(status) == "number" then status = get_status(status) end
	return strf("HTTP/1.1 %s\r\nServer: %s", status, phs.version)
end

local function send_response(client, resp)
	-- send the response to the client
	--   check the response elements
	--   concat the status line, the headers and the content
	--   send it to the client
	assert(type(resp) == "table", "send_response(): bad resp")
	assert(resp.status, "send_response(): status not defined")
	local statusline = get_statusline(resp.status)
	resp.content = resp.content or ""
	local h = list.concat(resp.headers, "\r\n")
	local data = statusline .. "\r\n".. h .. "\r\n\r\n" .. resp.content
	return msock.write(client, data)	
end--send_response

function phs.serve_client(client)
	-- process a client request:
	--    get a request from the client
	--    find a suitable handler in phs.request_dispatcher
	--    call the handler which returns a response
	--    send the response to the client
	--    close the client connection
	--    return to the server main loop
	--
	local vars = {} -- request variables (will be passed to the handler)
	-- log info about the client
	vars.client_ip, vars.client_port = msock.getclientinfo(client)
	log("serve client", vars.client_ip, vars.client_port)
	-- create the buffered read function
	local bufread = msock.bufreader(client) 
	-- get request headers and content if any
	local req, msg = receive_request(bufread, vars)
	if not req then 
		-- assume speculative connection (or other client issue)
		return msock.close(client)
	end	
	vars, errmsg = receive_headers(bufread, vars)
	if not vars then 
		-- assume other client issue. ignore it
		return msock.close(client) 
	end
	if vars.op == 'POST' then -- get content
		local size = tonumber(vars.HTTP_CONTENT_LENGTH)
		vars.content = bufread(size)
		-- in case of error, vars.content will be nil (not much to do)
	end
	--
	-- now dispach the request to the right handler
	-- 1st name in path is the name of the handler
	-- the handler is called with vars and the rest of path
	-- eg. url "/a/b/c" will be handled by calling handler 'a':
	--      phs.ht["a"](vars, "b/c")
	-- if the handler is not found, phs.ht.default() is used
	-- (remember path starts with a '/')
	local pt = ssplit(vars.reqpath, '/', 2)
	local hname = pt[2]
	vars.path = pt[3] or ""
	local handler = phs.ht[hname] or phs.ht.no_handler
	local resp = handler(vars)
	--
	-- send the response to the client
	send_response(client, resp)
	msock.close(client)
	return
end--serve_client()


------------------------------------------------------------------------
-- UTILITIES FOR REQUEST HANDLERS 
------------------------------------------------------------------------

-- socket functions should not be directly used here and below.

------------------------------------------------------------------------
-- encoded content - application/x-www-form-urlencoded

function phs.url_escape (str)
	-- (url_escape and url_unescape stolen from cgilua)
	str = string.gsub (str, "\n", "\r\n")
	str = string.gsub (str, "([^0-9a-zA-Z ])", -- locale independent
		function (c) return string.format ("%%%02X", 
			string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
end

function phs.url_unescape (str)
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)", 
		function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end

-- url-encoded data (from a post request) 
--    "AA=aa&BB=bbb+bb&CC=punct%3A+%2C.%2F%21@%23"


function phs.parse_urlencoded(data)
	-- parse content with type "application/x-www-form-urlencoded"
	-- ie. "name1=val1&name2=val2&..." where all names 
	-- and values are url-escaped
	-- return a table {argname=argvalue, ...}
	-- mutlivalued arguments are returned as a list:
	--   eg. {..., argname={val1, val2, val3}, ...}
	local unesc = phs.url_unescape
	local t = {}
	local function insval(k, v)
		k = unesc(k);  v = unesc(v) 
		if not t[k] then t[k]=v; return end
		if type(t[k]) == table then list.insert(t[k], v); return end
		t[k] = {t[k], v}; return
	end
	string.gsub (data, "([^&=]+)=([^&=]*)&?", insval)
	return t
end

function phs.parse_url(url)
	-- assume simple structure: <path>?<urlencoded-params>
	-- eg url = "/p1/p2/p3?a=aa&b=&c=cc+cc"
	--    returns "/p1/p2/p3", {a="aa", b="", c="cc cc"}
	local path, data, args
	if url:find("%?") then 
		path, data = url:match("^(.-)%?(.+)$")
		args = phs.parse_urlencoded(data)
	else
		path = url
		args = {}
	end
	return path, args
end

------------------------------------------------------------------------
-- encoded content - multipart/form-data

local repr=he.repr

function phs.parse_multipart(data)
	-- assume boundary is the first line (incl crlf)
	local datasize = #data
	local i, j, k, jh, kh --indices
	local boundary
	local parts = {}
	local part, head, partdata
	-- assume boundary is the first line (w/o crlf at end)
	-- assume all lines end with crlf - this supports no isolated lf!!
	i, j, boundary = string.find(data, "^(.-)\r\n")
	-- look for boundary at a beginning of line, 
	-- so, prefix boundary with crlf
	boundary = "\r\n" .. boundary  
	i = j + 1
	while i < datasize do
		-- i is at start of a part
		-- look for the end of the part headers
		jh, kh = string.find(data, "\r?\n\r?\n", i)
		if not jh then --end of headers not found
			--print("end of headers not found", i, jh, kh)
			break
		end
		-- look for boundary
		j, k = string.find(data, boundary, i, true)
		if not j then --boundary not found
			--print("remaining:", repr(data:sub(i)))
			break
		end
		-- make sure end of headers has been found *before* boundary
		assert(jh <= j, "error: no end of headers in current part")
		head = data:sub(i, jh-1)
		partdata = data:sub(kh+1, j-1)
		
		part = string.sub(data, i, j - 1)
		--print(i,j, k,  repr(part))
		list.insert(parts, {head=head, data=partdata})
		i = k + 3 --skip the crlf after the boundary
	end--while
	return parts
end


------------------------------------------------------------------------
-- prepare responses


function phs.add_header(resp, name, value)
	resp.headers = resp.headers or {}
	list.insert(resp.headers, strf("%s: %s", name, value))
	return resp
end

function phs.resp_content(content, mimetype)
	local resp = { status=200 }
	if type(content) ~= "string" then content = tostring(content) end
	mimetype = mimetype or "text/plain"
	resp.status = 200
	phs.add_header(resp, 'Content-Type', mimetype)
	phs.add_header(resp, 'Content-Length', tostring(#content))
	resp.content = content
	return resp
end

function phs.resp_html(content)
	return phs.resp_content(content, "text/html")
end

function phs.resp_redirect(href, status) 
	-- default redirect status is 302
	status = status or 302
	local resp = {}
	resp.status = get_status(status)
	local fmt
	resp.content = status .. " - Redirect to: " .. href
	phs.add_header(resp, 'Location', href)
	return resp
end	
	
function phs.resp_error(status, msg)
	local resp = {}
	local status = get_status(status)
	resp.status = status
	resp.content = msg and (status .. " - " .. msg) or status
	phs.add_header(resp, 'Content-Type', 'text/plain')
	phs.add_header(resp, 'Content-Length', tostring(#resp.content))
	return resp
end

function phs.resp_notfound(path)
	return phs.resp_error(404, path)
end

function phs.resp_badrequest(req)
	return phs.resp_error(400, req)
end



------------------------------------------------------------------------
-- mime types, serve file

phs.mimetypes = {
	["htm"] = "text/html",
	["html"] = "text/html",
	["css"] = "text/css",
	["txt"] = "text/plain",
	["gif"] = "image/gif",
	["png"] = "image/png",
	["jpg"] = "image/jpeg",
	["jpeg"] = "image/jpeg",
	["gif"] = "image/gif",
	["pdf"] = "application/pdf",
	["json"] = "text/plain",
	["lua"] = "text/plain",
	["i"] = "text/plain",
	[""] = "text/plain",
	-- for all other extensions, default is "application/octet-stream"
}	

function phs.guess_mimetype(fpath)
	local ext = he.fileext(fpath)
	ext = ext:lower()
	local mimetype = phs.mimetypes[ext] or "application/octet-stream"
	return mimetype
end

function phs.get_fullpath(fname)
	-- return the absolute pathname for a relative path 'fname'
	if fname:find("%.%.") then return nil, "invalid pathname" end
	if fname:match"^/" then 
		fname = phs.wwwroot .. fname
	else 
		fname = phs.wwwroot .. "/" .. fname
	end
	return fname
end

function phs.serve_file(path) 
	-- serve static files
	local fpath = phs.get_fullpath(path)
	if fpath and hefs.fexists(fpath) and hefs.isfile(fpath) then
		local mimetype = phs.guess_mimetype(fpath)
		local content = he.fget(fpath)
		return phs.resp_content(content, mimetype)
	else
		return phs.resp_notfound(path)
	end
end


------------------------------------------------------------------------
-- REQUEST HANDLERS 
------------------------------------------------------------------------


phs.ht = {}  -- the request handler table

-- the handler signature must be :  
--      h(vars) => resp = {status=n, headers={...}, content}
-- correctly formatted reponses are generated by phs utility functions
-- (phs.resp_content, resp_error, resp_notfound, ...)

function phs.ht.no_handler(vars)
	-- default handler, called when no handler found.
	return phs.resp_notfound("no handler for " .. vars.reqpath)
end

function phs.ht.exit_server(vars)
	phs.must_exit = true
	return phs.resp_content("Server shutdown.")
end

function phs.ht.reload_server(vars)
	phs.must_reload = true
	return phs.resp_html('<p>Server reload. Go to <a href="/">index page</a>')
end

function phs.ht.f(vars) -- serve static files - url: /f/path/of/file
	return phs.serve_file(vars.path)
end

function phs.ht.index(vars)
	local mimetype = "text/html"
	local content = he.fget('index.html')
	return phs.resp_content(content, mimetype)
end

phs.ht[""] = phs.ht.index -- default action for path = '/'

------------------------------------------------------------------------
return phs



--[===[  phs notes

---

Firefox connects to sites when hovering links... "speculative pre-connections feature". deactivate it:
   go to about:config 
   set network.http.speculative-parallel-limit to 0
see
https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_speculative-pre-connections

---

error 98 (cannot reuse address) just after exiting the server:
The server socket entered state TIME_WAIT (waiting for completion by
the client - up to some timeout. maybe ~ 1 min)

solution is to use socket option O_REUSEADDR

  What exactly does SO_REUSEADDR do?
  This socket option tells the kernel that even if this port is busy (in
  the TIME_WAIT state), go ahead and reuse it anyway.  If it is busy,
  but with another state, you will still get an address already in use
  error.  It is useful if your server has been shut down, and then
  restarted right away while sockets are still active on its port.  You
  should be aware that if any unexpected data comes in, it may confuse
  your server, but while this is possible, it is not likely.

int sockfd;
int option = 1;
sockfd = socket(AF_INET, SOCK_STREAM, 0);
setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &option, sizeof(option));
  
see http://stackoverflow.com/questions/15198834/bind-failed-error-address-already-in-use
http://www.softlab.ntua.gr/facilities/documentation/unix/unix-socket-faq/unix-socket-faq-2.html#time_wait

---

url-encoded data, from a post request
  "AA=aa&BB=bbb+bb&CC=punct%3A+%2C.%2F%21@%23"
or from a url (get request)
  http://127.0.0.1:3090/test/qqq?AA=aa&BB=bbb+bb&CC=punct%3A+%2C.%2F!@%23



]===]