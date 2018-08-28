
local function keys(t)
	local st = {}
	for k, v in pairs(t) do table.insert(st, k) end
	table.sort(st)
	return st
end

local libs = {
	'minisock',
}
--~ print(("-"):rep(72))
for i, lib in ipairs(libs) do
	local l = require(lib)
	local kl = keys(l)
	print(string.format(
		"%-15s %3d functions and constants (version: %s)", 
		lib, #kl, (l.VERSION or l._VERSION)))
	table.sort(kl)
 	print("...", table.concat(kl, ", "))
end

local he = require "he"
local ms = require "minisock"

--~ al = ms.getaddrinfo("google.com", "80")
al = ms.getaddrinfo("google-public-dns-a.google.com", "80")
--~ addr = al[1]
--~ print(ms.getnameinfo(addr))
--~ print(ms.getnameinfo(addr, true))
--~ print(#al)
--~ he.pp(al)
he.list.map(al, function(x) 
	print(#x, ms.getnameinfo(x, true), ms.getnameinfo(x))
	print("   hex:", he.stohex(x, 72, " "))
	end)
print("LH", ms.getnameinfo("\2\0\0\80\8\8\8\8\0\0\0\0\0\0\0\0"))
print("LH", ms.getnameinfo("\2\0\0\80\127\0\0\1\0\0\0\0\0\0\0\0", true))
print("LH", ms.getnameinfo("\2\0\0\80\0\0\0\0\0\0\0\0\0\0\0\0"))

