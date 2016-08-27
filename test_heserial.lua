
-- heserial unit tests

local he = require "he"
local hs = require "heserial"

local list = he.list
local pp = he.pp
local ser, deser = hs.serialize, hs.deserialize

--test equality including the metatable
local function eq(a, b) return he.equal(a, b, true) end

------------------------------------------------------------------------
local s, t, u, v, w

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


------------------------------------------------------------------------
--~ print("test_heserial", "ok")

return true
