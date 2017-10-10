
he = require "he"
msock = require "msock"

if he.windows then
--~ 	os.execute('start /MIN cmd /c "lua -e require[[henb]].serve() & pause" ')
	os.execute('start /MIN cmd /c "lua -e require[[henb]].serve()" ')
else
	os.execute'slua -e "require[[henb]].serve()"  &'
	msock.msleep(100)
	print'ok'
end

nb = require "henb"
--~ he.pp(nb)

rblob, rcode = nb.nop()
assert(rblob == "" and rcode == nil)

rblob, rcode = nb.cmd(123, "abcdef")
assert(rblob == nil and rcode == nb.status.UNKNOWN)

rblob, rcode = nb.put("abcdef")
assert(rcode == nil and rblob ==
	"dde410524e3569b303e494aa82a3afb3e426f9df24c1398e9ff87aafbc2f5b7b")

rblob, rcode = nb.get("abcdef")
assert(rblob == nil and rcode == nb.status.NOTFOUND)

rblob, rcode = nb.get(
	"dde410524e3569b303e494aa82a3afb3e426f9df24c1398e9ff87aafbc2f5b7b")
assert(rblob == "abcdef" and rcode == nil)

rblob, rcode = nb.exit_server() 
assert(rblob == "" and rcode == nil)

assert(os.remove(
	"dde410524e3569b303e494aa82a3afb3e426f9df24c1398e9ff87aafbc2f5b7b"))


