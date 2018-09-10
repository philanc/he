-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

=== rblob - submitting blob requests to phs


]]

------------------------------------------------------------------------
-- tmp lua path adjustment if needed
package.path = "../?.lua;" .. package.path


------------------------------------------------------------------------
-- imports and local definitions

local he = require 'he'
local hefs = require 'hefs'
local hesock = require 'hesock'
local hehs = require 'hehs'
local hepack = require 'hepack'

local list, strf, printf, repr = he.list, string.format, he.printf, he.repr
local ssplit = he.split
local startswith, endswith = he.startswith, he.endswith
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

local function log(...)
	print("rblob " .. he.isodate():sub(10), ...)
end



------------------------------------------------------------------------
-- http utilities  --duplicated from hehs.lua FIXIT


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

local function receive_status(so, vars)
	-- receive status line (first line of the response)
	-- eg:  HTTP/1.1 400 Bad Request
	local s, msg = so:read()
	if not s then return nil, msg end
	local scode, smsg = string.match(s, '^%S+%s+(%d+)%s?(.*)')
	scode = tonumber(scode)
	vars.status = scode
	vars.status_msg = smsg or get_status(scode)
	return scode
end

local function receive_headers(so, vars)
	-- process headers from a connection 
	-- (borrowed from orbiter/luasocket)
	-- return headers table {headername=headervalue, ...} and remaining
	-- unread content of the read buffer if any
	-- note that the variables names are uppercased and have '-' replaced
	-- with '_' to make them WSAPI compatible (e.g. HTTP_CONTENT_LENGTH)
	local line, name, value, err
	-- get first line
	line = assert(so:read(), "receiving header 1st line")
	while line ~= "" do  -- headers go until a blank line is found
--~ 		print('=', line)
		-- get field-name and value
		name, value = line:match "^(.-):%s*(.*)"
		assert(name and value, "malformed reponse headers")
		name = 'HTTP_'..name:upper():gsub('%-','_')
		-- get next line (value may be folded)
		line = so:read()
		if not line then error(err .. " (receiving header line)") end
		-- unfold any folded values
		while line:find("^[ \t]") do
			value = value .. line
			line = assert(so:read(), 
				"receiving header continuation line")
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





------------------------------------------------------------------------
-- rblob

local rblob = he.class()


function rblob.http_request(rb, s, get_flag)
	-- send a http request to remote blob server rb
	-- if get_flag is false or empty (default) the request is 
	-- a POST on path rb.path, with string s as content.
	-- if get_flag is true, the request is a GET
	-- with path = rb.path .. s
	-- return the content returned by the server or nil, errmsg
	local so, msg, r, tpl, hreq, resp
	so, msg = hesock.connect(rb.rawaddr)
	if not so then return nil, msg end
	if get_flag then
		hreq = strf("GET %s%s HTTP/1.1\r\nHost: rb\r\n\r\n",
			rb.path, s)
	else 
		hreq = strf("POST %s HTTP/1.1\r\nHost: rb\r\n"
		.. "Content-Length: %s\r\n\r\n%s", rb.path, #s, s)
	end
	r, msg = so:write(hreq)
	if not r then return nil, msg end
	local vars = {}
	local scode = receive_status(so, vars)
	receive_headers(so, vars)
	print(333, he.t2s(vars))
	local c, clen
	clen = tonumber(vars.HTTP_CONTENT_LENGTH)
	if not clen then return nil, "no Content-Length in response" end
	c = so:read(clen)
	so:close()
	return c
end
	
	



------------------------------------------------------------------------
-- test request using hehs default 'raw_echo' handler

local rb = rblob()

rb.debug_mode = true

-- log function. default is to print messages to stdout.
rb.log = log  

-- phs raw address  (localhost:3090)
rb.rawaddr = '\2\0\x0c\x12\127\0\0\1\0\0\0\0\0\0\0\0'

-- default raw_echo handler
rb.path = "/echo"


local c = rb:http_request("hello, world!")
print('POST', repr(c))

local c = rb:http_request(hehs.url_escape("hello, world!"))
print('GET', repr(c))

s = ('\0'):rep(10000) .. '\1'
c = rb:http_request(s, true)
print(#s, #c)
assert(s == c)


------------------------------------------------------------------------
-- run 








--[===[  rblob notes

	-- reqt is a _simple table_ (see hepack.lua) ie a table 
	-- containing only numbers, strings, boolean and other simple 
	-- tables. no cycle allowed.
	-- return blob server response as a table or nil, errmsg
	if type(reqt) == "table" then 
		req = hepack.pack(reqt)
	else
		req = reqt
	end
	if rb.key then req = rb:encrypt(req) end


---

HTTP 0.9 -- The Original HTTP as defined in 1991 ... This is a subset of the full HTTP protocol, and is known as HTTP 0.9. 
https://www.w3.org/Protocols/HTTP/AsImplemented.html

Request: only on one line:	GET /path<crlf>

Response: the content (html text) w/o any status and header line.
The message is terminated by the closing of the connection by the server. 
 

 

---

url-encoded data, from a post request
  "AA=aa&BB=bbb+bb&CC=punct%3A+%2C.%2F%21@%23"
or from a url (get request)
  http://127.0.0.1:3090/test/qqq?AA=aa&BB=bbb+bb&CC=punct%3A+%2C.%2F!@%23

---


http request:
	POST /cgi-bin/process.cgi HTTP/1.1
	User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
	Host: www.tutorialspoint.com
	Content-Type: application/x-www-form-urlencoded
	Content-Length: length
	Accept-Language: en-us
	Accept-Encoding: gzip, deflate
	Connection: Keep-Alive

	... some content ...

http response:
	HTTP/1.1 400 Bad Request
	Date: Sun, 18 Oct 2012 10:36:20 GMT
	Server: Apache/2.2.14 (Win32)
	Content-Length: 230
	Content-Type: text/html; charset=iso-8859-1
	Connection: Closed
	  
	<html>
	... some content, eg error msg...
	</html>


]===]