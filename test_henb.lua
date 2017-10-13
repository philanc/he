
he = require "he"
hesock = require "hesock"

if he.windows then
--~ 	os.execute('start /MIN cmd /c "slua -e require[[henb]].serve() & pause" ')
	os.execute('start /MIN cmd /c "slua -e require[[henb]].serve() " ')
--	add "& pause" after ...serve() to view server output
else
	os.execute'slua -e "require[[henb]].serve()"  &'
	hesock.msleep(100)
end

local nb = require "henb"
--~ he.pp(nb)


local blob, rblob, rcode, rmsg, h, ha, hb


-- ensure hash() is ok
assert(#nb.hash"abc" == nb.hashlen)
ha = nb.hash("abcdef")
assert(ha ==
	"dde410524e3569b303e494aa82a3afb3e426f9df24c1398e9ff87aafbc2f5b7b")
hb = nb.hash("blobname")
assert(hb ==
	"7c77c6c3fb0c766138633b4ab7ad9f60b83fe55c6dcf256adc696f8a3982191b")


rblob, rcode = nb.nop()
assert(rblob == "" and rcode == nil)

rblob, rcode = nb.cmd(123, "abcdef")
assert(rblob == nil and rcode == nb.status.UNKNOWN)

rblob, rcode = nb.put("abcdef")
assert(rcode == nil and rblob == ha)

rblob, rcode = nb.get("xyzzy")
assert(rblob == nil and rcode == nb.status.NOTFOUND)

rblob, rcode = nb.get(ha)
assert(rblob == "abcdef" and rcode == nil)

rblob, rcode = nb.putid("abcdef", "blobname")
assert(rcode == nil and rblob == ha)

rblob, rcode = nb.getid("blobname")
assert(rcode == nil and rblob == "abcdef")

rblob, rcode = nb.chk(ha)
assert(rblob == ha)
rblob, rcode = nb.chk(hb)
assert(rblob == ha) -- blob content hash
rblob, rcode = nb.chk("xyzzy")
assert(rblob == nil and rcode == nb.status.NOTFOUND)

rblob, rcode = nb.del(ha)
assert(rblob == true)
rblob, rcode = nb.get(ha)
assert(rblob == nil and rcode == nb.status.NOTFOUND)
rblob, rcode = nb.del(ha)
assert(rblob == nil and rcode == nb.status.DELERR)

rblob, rcode = nb.del(hb) -- also delete "blobname"
assert(rblob == true)

rblob, rcode = nb.exit_server() 
assert(rblob == "" and rcode == nil)

-- os.remove(ha) works only when executed in blobs directory
-- assert(os.remove(ha)) 
-- assert(os.remove(hb))

