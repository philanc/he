--require "heap"
he = require "he"

nb = require "henb"
--~ he.pp(nb)
print( 'nop1', nb.nop() )
print( 'nop2', nb.nop() )
print( 'c123', nb.cmd(123, "abcdef") )
h, msg = nb.put("abcdef")
print('put', h, msg)
print('get abc', nb.get("abcdef"))
print('get h ', nb.get(h))
print( 'exit', nb.exit_server() )
