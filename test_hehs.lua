
--[[

=== test_hehs


]]

local he = require "he"
local hehs = require "hehs"

-- to be fixed!
cmd = " (sleep 1 ; wget -q localhost:3090/exit_server ; rm exit_server ) & "
os.execute(cmd)
hehs.serve()




