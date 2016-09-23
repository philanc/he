-- test_term.lua

------------------------------------------------------------------------
-- some local definitions

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack
local app, concat = table.insert, table.concat

local repr = function(x) return strf("%q", tostring(x)) end

------------------------------------------------------------------------
local term = require "term"

local out = term.out
local outf = term.outf
local outdbg = term.outdbg

------------------------------------------------------------------------
local he = require"he"
he.interactive()
ln = require"linenoise"

local sl, sc -- screen lines, columns
local out, go, color = term.out, term.golc, term.color
local cleareol = term.cleareol
local col = term.colors

local sf = string.format
local flush = io.flush

local put = function(l, c, s)
	go(l, c); out(s)
end

local style = {
	[1] = function() color(col.normal) end, 
	[2] = function() color(col.red, col.bold) end, 
	[3] = function() color(col.green) end, 
	[5] = function() color(col.red, col.bgblack) end, 
}

local put = function(l, c, y, s) -- y is style number
	go(l, c); style[y](); outf(s)
end

local puteol = function(l, c, y, s) -- y is style number
	go(l, c); cleareol(); style[y](); outf(s)
end

local coord = function(l, c) return sf("l=%d c=%d", l, c) end
local paintcorners = function()
	local nw = coord(1, 1); 	puteol(1, 1, 2, nw)
	local ne = coord(1, sc);	puteol(1, sc-#ne+1, 2, ne)
	local sw = coord(sl, 1);	puteol(sl, 1, 2, sw)
	local se = coord(sl, sc); 	puteol(sl, sc-#se+1, 2, se)
end

function t3()
--~ 	omode = ln.getmode()
--~ 	ln.setrawmode()
--~ 	os.execute("stty raw -echo 2> /dev/null")
	prevmode, e, m = term.savemode()
	if not prevmode then print(prevmode, e, m); os.exit() end
	term.setrawmode()
	nextk = term.input()
--~ 	he.fput('zzr', he.shell('stty -g'))
	while true do
		term.reset()
		sl, sc = term.getscrlc(); paintcorners()
		put(3, 10, 1, "Press any key")	
		put(4, 10, 1, "^Q   exit")	
		put(5, 10, 1, "^L   redisplay")	
		while true do
			k = nextk()
			if k == byte'Q'-64 then break end
			if k == byte'L'-64 then goto continue end
			puteol(3, 30, 3, term.keyname(k)); 
			term.hide(); --hide cursor
			flush()
		
		end
		break
		::continue::
	end
	term.show() -- show cursor
	go(sl, 1); style[1](); flush()
--~ 	ln.setmode(omode)
--~ 	os.execute("stty sane")
	term.restoremode(prevmode)

end

t3()

