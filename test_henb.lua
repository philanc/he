
he = require "he"
hesock = require "hesock"

--  [==[
if he.windows then
--~ 	os.execute('start /MIN cmd /c "slua -e require[[henb]].serve() & pause" ')
	os.execute('start /MIN cmd /c "slua -e require[[henb]].serve() " ')
--	add "& pause" after ...serve() to view server output
else
	os.execute'slua -e "require[[henb]].serve()"  &'
	hesock.msleep(100)
end
--  ]==]

local nb = require "henb"
--~ he.pp(nb)


local blob, rblob, rcode, rmsg, h, ha, hb


rblob, rcode = nb.nop()
assert(rblob == "" and rcode == nil)

rblob, rcode = nb.cmd(123, "abcdef")
assert(rblob == nil and rcode == nb.status.UNKNOWN)

rblob, rcode = nb.put("ab", "abcdef")
assert(rblob == "")

rblob, rcode = nb.get("xyzzy")
assert(rblob == nil and rcode == nb.status.NOTFOUND)

rblob, rcode = nb.get("ab")
assert(rblob == "abcdef" and rcode == nil)

bln, rcode = nb.chk("ab")
assert(bln == 6)
bln, rcode = nb.chk("xyzzy")
assert(bln == nil and rcode == nb.status.NOTFOUND)

rblob, rcode = nb.del("ab")
assert(rblob == "")
rblob, rcode = nb.get("ab")
assert(rblob == nil and rcode == nb.status.NOTFOUND)
rblob, rcode = nb.del("ab")
assert(rblob == nil and rcode == nb.status.DELERR)


rblob, rcode = nb.exit_server() 
assert(rblob == "" and rcode == nil)

-- os.remove(ha) works only when executed in blobs directory
-- assert(os.remove(ha)) 
-- assert(os.remove(hb))

