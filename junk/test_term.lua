

------------------------------------------------------------------------
-- some local definitions

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack
local app, concat = table.insert, table.concat
local yield = coroutine.yield

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


--[[

--~ pp(ln)
if not ln.isatty(1) then exit(1) end
col = term.colors

term.color(col.white, col.bgblack)
term.color(col.normal)

--~ term.clear()
--~ term.golc(1,1)
--~ term.output(term.scrsize())
--~ term.golc(3, 20)
--~ term.color(col.white, col.bgred, col.reverse)
--~ term.color(col.reverse)
--~ term.color(col.red, col.bold)
--~ term.color(col.red)
--~ term.output(he.isodate(), "\t\t!!!")
--~ term.output("\r")
--~ term.output("XXZZ\n")
--~ term.color(col.white, col.bgblack, col.normal)
--~ term.color(col.normal)
--~ term.color(col.normal)
--~ term.reset()
--~ term.color(col.yellow, col.reverse)
--~ term.output(he.isodate())

local outr = term.outdbg
local outx = function(x) out(strf("%02X ", x)) ; io.flush() end
local outx = function(x) out(strf("%d ", x)) ; io.flush() end
local nextk = term.input()

--~ outx = function(x) outr(char(x)) end
--~ local nextk = term.rawinput()

local nextc = function() return string.char(nextk()) end
omode = ln.getmode()

-- request cursor position
print"cursor position (esc 6n) - press '.' to exit"
ln.setrawmode()

l, c = term.getscrlc()
term.color(col.red, col.bold)
io.write(l, ' ', c, ': '); io.flush()
term.color(col.normal)

--~ while not morekeys() do outf('='); sleep(1) end ; goto reset

--~ outf("\027[6n")
while true do
--~ 	local c = io.read(1)
	local k = nextk()
	if k == nil then outx(0x100000) ; break end
	if k == byte'.' then break end
--~ 	outf(repr(c))
	local name = term.getkeyname(k)
	if name then
		outf(name .. " ") 
	else 
		outx(k)
	end
end

::reset::
ln.setmode(omode)


-- ]]
-- [[
function t2()
	omode = ln.getmode()
	ln.setrawmode()
	outf"press a key..."
	l, c = term.getscrlc()
--~ 	outf(repr(l), ' ')
--~ 	outf(repr(c), ' ')
	outdbg(l, ' ')
	outdbg(c, ' ')

	outf"done."
	ln.setmode(omode)
end

t2()

-- ]]

------------------------------------------------------------------------
return term

