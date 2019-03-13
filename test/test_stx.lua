
--[[

=== test_hestx


]]

local he = require "he"
local stx = require "he.stx"

local list = he.list
local eq = he.equal
local x, y, h, itl
local pp, ppl, ppt = he.pp, he.ppl, he.ppt

------------------------------------
-- parseitext
x, y = stx.parseitext('\t')
assert(eq({x,y}, {"", {}}))
x, y = stx.parseitext('  a  ')
assert(eq({x,y}, {"a", {}}))

x,y = stx.parseitext('\n\n\n\n=== a\n=== b')
assert(eq({x,y}, {"", {	{"a", ""}, {"b", ""}, }}))
x,y = stx.parseitext('\n\n\n\n=== a\nt\n=== b')
assert(eq({x,y}, {"", {	{"a\nt", ""}, {"b", ""}, }}))
x,y = stx.parseitext('\n\n\n\n=== a\n\n\n\n t\n=== b')
assert(eq({x,y}, {"", {	{"a", " t"}, {"b", ""}, }}))

x,y = stx.parseitext('\n\n===\n\n===\n\n\n===')
assert(eq({x,y}, {"", {}}))
x,y = stx.parseitext('\n\n===\n\n=== TOC\n\n blabla \n\n===')
assert(eq({x,y}, {"", {}}))

------------------------------------
-- makeitext
x = stx.makeitext(list{ {"title", ""}, })
assert(x == "=== title\n\n\n")
x = stx.makeitext(list{ {"title", " abc"}, })
assert(x == "=== title\n\n abc\n\n\n")
x = stx.makeitext(list{ {"title", " abc"}, {"t2", "" }, })
assert(x == "=== title\n\n abc\n\n\n=== t2\n\n\n")
x = stx.makeitext(list{ {"title", " abc"}, }, "head")
assert(x == "head\n\n\n=== title\n\n abc\n\n\n")
x = stx.makeitext(list{ {"t", " abc"}, {"t2", "" }, }, "h", true)
assert(x == "h\n\n\n=== TOC\n\nt\nt2\n\n\n=== t\n\n abc\n\n\n=== t2\n\n\n")
x = stx.makeitext(list{ {"t", " abc"}, {"t2", "" }, }, "", true)
assert(x == "=== TOC\n\nt\nt2\n\n\n=== t\n\n abc\n\n\n=== t2\n\n\n")

itl = list{ {"t", " abc"}, {"t2", "" }, }
x = stx.makeitext(itl, nil, true)
assert(x == "=== TOC\n\nt\nt2\n\n\n=== t\n\n abc\n\n\n=== t2\n\n\n")

-- round trip
h, itl = stx.parseitext(x)
assert(h == "" and eq(itl, list{ {"t", " abc"}, {"t2", "" }, }))

------------------------------------





