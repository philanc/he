
local he = require "he"
local getopt = require("hegetopt").getopt

local eq = he.equal
local pp, ppt = he.pp, he.ppt

--simple, only positional
al = { "f1",  "f2", }
ot, msg = getopt("o:hz:v", al)
assert(eq(ot, {"f1", "f2"}))

--simple
al = { "-h",  "f1",  "f2", }
ot, msg = getopt("ABo:hz:v", al)
assert(eq(ot, {"f1", "f2", h=true}))

--simple, with --
al = { "-h",  "--", "f1",  "f2", }
ot, msg = getopt("ABo:hz:v", al)
assert(eq(ot, {"f1", "f2", h=true}))

--simple, with -- and arg starting with '-'
al = { "-h",  "--", "---f1",  "-f2", }
ot, msg = getopt("ABo:hz:v", al)
assert(eq(ot, {"---f1", "-f2", h=true}))

-- unknown option -a
al = { "-h", "-v", "-a", "out",  "f1",  "f2" }
ot, msg = getopt("o:hz:v", al)
assert(not ot)

-- group
al = { "-z", "zzz", "-h", "-v", "-hvo", "out",  "f1",  "f2"  }
ot, msg = getopt("o:hz:v", al)
assert(eq(ot, {"f1", "f2", h=true, o="out", v=true, z="zzz"}))

-- no positional
al = { "-z", "zzz", "-h", "-v", "-hvo", "out",  }
ot, msg = getopt("o:hz:v", al)
assert(eq(ot, {h=true, o="out", v=true, z="zzz"}))

-- no positional, -o not at end of group
al = { "-z", "zzz", "-h", "-v", "-hov", "out",  }
ot, msg = getopt("o:hz:v", al)
assert(not ot)

-- optstring error (digit not allowed)
al = { "-h",  "f1",  "f2", }
ot, msg = getopt("h6z:v", al)
assert(not ot)
assert(msg:match"invalid option string: ")

--~ print(ot, msg); ppt(ot)

