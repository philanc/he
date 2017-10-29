
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

local henb = require "henb"
--~ he.pp(nb)


local cli, blob, rblob, rcode, rmsg, h, ha, hb

cli = henb.newclient()

rblob, rcode = cli:nop()
assert(rblob == "" and rcode == nil)

rblob, rcode = cli:cmd(123, "abcdef")
assert(rblob == nil and rcode == henb.UNKNOWN)

rblob, rcode = cli:put("ab", "abcdef")
assert(rblob == "")

rblob, rcode = cli:get("xyzzy")
assert(rblob == nil and rcode == henb.NOTFOUND)

rblob, rcode = cli:get("ab")
assert(rblob == "abcdef" and rcode == nil)

bln, rcode = cli:chk("ab")
assert(bln == 6)
bln, rcode = cli:chk("xyzzy")
assert(bln == nil and rcode == henb.NOTFOUND)

rblob, rcode = cli:del("ab")
assert(rblob == "")
rblob, rcode = cli:get("ab")
assert(rblob == nil and rcode == henb.NOTFOUND)
rblob, rcode = cli:del("ab")
assert(rblob == nil and rcode == henb.DELERR)


rblob, rcode = cli:exit_server() 
assert(rblob == "" and rcode == nil)

-- os.remove(ha) works only when executed in blobs directory
-- assert(os.remove(ha)) 
-- assert(os.remove(hb))

