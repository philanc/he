
--[[

=== test_phs


]]

local he = require "he"
local phs = require "phs"

-- to be fixed!
cmd = " (sleep 1 ; wget -q localhost:3090/exit_server ; rm exit_server ) & "
os.execute(cmd)
phs.serve()




