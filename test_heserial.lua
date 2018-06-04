--[[

=== test_heserial


]]

local he = require "he"
local hs = require "heserial"

local list = he.list
local pp = he.pp
local pack, unpack = hs.pack, hs.unpack
local ser, deser = hs.serialize, hs.deserialize

--test equality including the metatable
local function eq(a, b) return he.equal(a, b, true) end

------------------------------------------------------------------------
local s, t, u, v, w
assert(unpack(pack( 0 )) == 0 )
assert(unpack(pack( -1 )) == -1 )
assert(unpack(pack( -2 )) == -2 )
assert(unpack(pack( 239 )) == 239 ) --0xef
assert(unpack(pack( 1000 )) == 1000 )
assert(unpack(pack( 1.02 )) == 1.02 )
assert(unpack(pack( "" )) == "" )
assert(unpack(pack( "aaa" )) == "aaa" )
assert(unpack(pack( ('a'):rep(10000) )) == ('a'):rep(10000) )
assert(unpack(pack( ('a'):rep(1000000) )) == ('a'):rep(1000000) )
assert(eq({}, unpack(pack( {} ))))
assert(eq({{{}}}, unpack(pack( {{{}}} ))))
t = {{a={'aaa'}}, 11, 22}
assert(eq(t, unpack(pack( t ))))
l = he.list{{a={'aaa'}}, 11, 22}
assert(eq(l, unpack(pack( l ))))

-- regular table literals
t = {11, 22, name="abc", {}, {{}}, {x=1, y=1.0}}
s = ser(t)
--~ print(s)
u = deser(s)
assert(eq(t, u))

-- same with lists (he.list)
t = list{11, 22}
s = ser(t)
u = deser(s)
assert(eq(t, u))
assert(not eq(u, {11, 22}))

t = {11, y=22, list{33,55}}
s = ser(t)
--~ print(s)
u = deser(s)
assert(eq(t, u))



