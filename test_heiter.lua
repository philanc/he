local he = require "he"
local iter = require "heiter"

local odd = function(i) return i % 2 == 1 end

local t, t1, t2, i, l, x
local txt, fh, msg



-- count, filter, take
-- also verify that :dbg() and :check_err() do not change the result 
t = {}
for i in iter.count(10,3)
	:filter(odd)
	:take(3) 
	:dbg('---dbg ok.')
	:check_err()
	do t[#t+1] = i end
assert(he.equal(t, {13, 19, 25}))

-- collect
t = {11,22,33}
assert(he.equal(t, iter.items(t):collect()))
t = iter.count(10,3):filter(odd):take(3):collect(); 
assert(he.equal(t, {13, 19, 25}))

--first
assert(iter.count():first() == 1)

-- map
t = iter.count(10,3):filter(odd)
	:map(function(x) return 2*x end)
	:take(3):collect(); 
assert(he.equal(t, {26, 38, 50}))


-- flines()
txt = [[require "test_he"
== oops
require "test_hefs"
require "test_hecsv"<eof>]]
he.fput('zz', txt)
t = {}
for l in iter.flines('zz')
	:map(string.upper)
	:filter(function(l) return not l:match("^==") end)
	do t[#t+1] = l end
assert(t[2] == [[REQUIRE "TEST_HEFS"]])
-- flines works also with a handle
fh, msg = io.open('zz')
--~ for l in iter.flines(fh) do print(l) end
assert(iter.flines(fh):first() == [[require "test_he"]])
-- check fh has not been closed
assert(io.type(fh) == 'file')
assert(fh:close())


-- matching
l = iter.flines('zz'):map(string.upper):matching("FS"):first()
assert(l == [[REQUIRE "TEST_HEFS"]])



