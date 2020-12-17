-- Copyright (c) 2019  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------

--[[

=== test_all - test all modules

if test modules return a string when required, it is displayed 
by the test function below.  (see eg. test_nacl)


]]

package.path="./?.lua;./?/init.lua;" .. package.path

local function test(mod)
	local r = require("test.test_" .. mod)
	local msg = (type(r) == "string") and r or "ok"
	print(string.format("test_%-15s \t%s", mod, msg))
end

------------------------------------------------------------------------
test "he"

