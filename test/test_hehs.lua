
--[[

=== test_hehs


]]

local he = require "he"
local hehs = require "he.hs"

-- to be fixed!
cmd = " (sleep 1 ; wget -q -O /dev/null  localhost:3090/server/exit  ) & "
os.execute(cmd)
hehs.serve()




