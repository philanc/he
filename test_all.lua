-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

local function test(mod)
	require("test_" .. mod)
	print(string.format("test_%-15s \tok", mod))
end

------------------------------------------------------------------------
test "he"
test "hefs"
test "hecsv"
test "hezen"
test "henacl"
test "hegetopt"
test "heserial"

