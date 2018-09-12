-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

=== phs - a tiny HTTP server based on hehs


]]

------------------------------------------------------------------------
-- tmp path adjustment
package.path = package.path .. ";../?.lua"

------------------------------------------------------------------------
-- imports and local definitions

local he = require 'he'
local hefs = require 'hefs'
local hezen = require 'hezen'
local hepack = require 'hepack'

local list, strf, printf, repr = he.list, string.format, he.printf, he.repr
local spack, sunpack = string.pack, string.unpack
local ssplit = he.split
local startswith, endswith = he.startswith, he.endswith
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

local function repr(x)
	return strf("%q", x) 
end

local function log(...)
	print(he.isodate():sub(10), ...)
end



------------------------------------------------------------------------
-- phs configuration

phs = require "hehs"


-- bind raw address  (localhost:3090)
phs.localaddr = '\2\0\x0c\x12\127\0\0\1\0\0\0\0\0\0\0\0'
-- bind_address = '::1'    -- for ip6 localhost

phs.wwwroot = '.' -- serve from the current directory
phs.home_default = '/phshome.html'

-- server state
phs.must_exit = nil  -- server main loop exits if true 
		     -- handlers can set it to an exit code
		     -- convention: 0 for exit, 1 for exit+reload

-- debug_mode
-- true => request handler is executed without pcall()
--	   a handler error crashes the server
phs.debug_mode = true

-- server log function
-- default is to print messages to stdout.
phs.log = log  

------------------------------------------------------------------------
-- test handler


--set test handlers: GET, POST (urlencoded and multipart)

local heserial = require "heserial"


function phs.handlers.test(vars)
	local path = vars.path
	if vars.op == "GET" then
		print("test GET   path:", path)
		print("params:", he.t2s{phs.parse_url(path)})
		local txt = strf("test_get: path = %s\ncontent:\n", path) 
		txt = txt .. he.t2s{phs.parse_url(path)} .. "\nvars:\n"
		txt = txt .. he.t2s(vars)
		return phs.resp_content(txt)
	end --if get
	-- assume it is a POST request
	print("test_post:   path:", path)
	print("test_post:   content length:", #vars.content)
--~ 	he.fput('fdata', vars.content)
	local txt = strf("test_post: path = %s\ncontent:\n", path) 
	if startswith(path, 'mp') then --multipart
		txt = txt .. heserial.serialize(phs.parse_multipart(vars.content))
	elseif startswith(path, 'ue') then --url-encoded
		local ut = phs.parse_urlencoded(vars.content)
--~ 		local upa, ut = phs.parse_url(vars.content)
--~ 		log('upa, ut', upa, ut)
		txt = txt .. he.t2s(ut)
	elseif startswith(path, 'pt') then --plain/text
		txt = txt .. '\nvars.content:\n' .. vars.content
	elseif startswith(path, 'bin') then --raw binary
		txt = txt .. repr(vars.content)
	else
		txt = heserial.serialize(vars)
	end--if
	return phs.resp_content(txt)
end

function phs.handlers.testdat(vars)
	local path = vars.reqpath
	local fpath, msg = phs.get_fullpath(path)
	if not fpath then return phs.resp_badrequest(msg) end
	if vars.op == "GET" then
		local content = he.fget(fpath)
		return phs.resp_content(content, "application/octet-stream")
	elseif vars.op == "POST" then
		he.fput(fpath, vars.content)
		return phs.resp_content("Done.")
	else
		return phs.resp_badrequest("Unknown op: " .. vars.op)
	end
end


------------------------------------------------------------------------
-- rb handler

local function encrypt(key, nonce, m, ctr)
	-- encrypt m with key, nonce
	-- return the encrypted message c prefixed with the nonce
	-- => #c = 16 + 8 + #m + 16 = #m + 40
	--
	return hezen.morus_encrypt(key, nonce, m, ctr)
end

local function decrypt(key, nonce, c, ctr)
	-- return decrypted message, nonce or nil errmsg if MAC error
	return hezen.morus_decrypt(key, nonce, c, ctr)
end

local function rb_action(req)
	local res, status = he.shell(req .. " 2>&1 ")
	return strf("status=%s\n[%s]", tostring(status), res)
end

local function rb_handler(vars)
	local msg, ereq, req, resp, eresp, nonce, ctr
	local ereq = vars.content
	nonce, ctr = sunpack("<c16I8", ereq)
	ereq = ereq:sub(25)
	local req, msg = decrypt(phs.key, nonce, ereq, ctr)
	if not req then 
		return phs.resp_error(400, "invalid req") 
	end
	local resp, msg = rb_action(req)
	eresp = encrypt(phs.key, nonce, resp, ctr + 1)
	return phs.resp_content(eresp)
end

phs.handlers.rb = rb_handler



	




------------------------------------------------------------------------
-- run 

--~ he.pp(hezen)

phs.key = ('k'):rep(32)

phs.serve()







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