-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

--[[

=== test_all - test all modules

if test modules return a string when required, it is displayed 
by the test function below.  (see eg. test_nacl)


]]

local function test(mod)
	local r = require("test_" .. mod)
	local msg = (type(r) == "string") and r or "ok"
	print(string.format("test_%-15s \t%s", mod, msg))
end

------------------------------------------------------------------------
test "he"
test "hefs"
test "hecsv"
test "hezen"
test "henacl"
test "hegetopt"
test "hepack"
test "henat"
test "hebs"
test "stx"
test "hesock"
test "hehs"

