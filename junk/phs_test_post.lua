
--[[ 

run phs with some GET and POST test handlers


]]

------------------------------------------------------------------------
-- local defs

local he = require 'he'
local hefs = require 'hefs'
local heserial = require 'heserial'

local list, strf, printf, repr = he.list, string.format, he.printf, he.repr
local yield = coroutine.yield
local ssplit = he.split
local startswith, endswith = he.startswith, he.endswith
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

local phs = require "phs"

------------------------------------------------------------------------
--set test handlers: GET, POST (urlencoded and multipart)

function phs.ht.test(vars)
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
		txt = txt .. he.t2s(phs.parse_url(vars.content))
	elseif startswith(path, 'pt') then --plain/text
		txt = txt .. '\nvars.content:\n' .. vars.content
	elseif startswith(path, 'bin') then --raw binary
		txt = txt .. repr(vars.content)
	else
		txt = heserial.serialize(vars)
	end--if
	return phs.resp_content(txt)
end

function phs.ht.testdat(vars)
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


------------------------------------------------------------
-- run 

phs.serve()

