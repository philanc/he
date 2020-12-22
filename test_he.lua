-- Copyright (c) 2019  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[

=== test_he


]]

--~ package.path="./?.lua;./?/init.lua"

local he = require 'he'
assert(he)

print(he.VERSION)

-- make sure we test the correct version
assert(he.VERSION:match("^he109,"), "bad he version")

-- check that _G and string are not extended
assert(not _G.he)
assert(not string.split)

-- some local defs for all the tests
local list = he.list
local pp, ppl, ppt = he.pp, he.ppl, he.ppt
--
local a, b, c, d, f, k, l, l2, s, t, u, v, x, y

------------------------------------------------------------------------
-- test string functions

assert(he.startswith('123 456', ''))
assert(he.startswith('123 456', '12'))
assert(not he.startswith('123 456', '.*'))
assert(he.endswith('123 456', ''))
assert(he.endswith('123 456', '56'))
assert(he.endswith('123 456', '123 456'))
assert(not he.endswith('123 456', '0123 456'))
assert(not he.endswith('123 456', '.*'))

s = 'ab=c\tde   f==' --do not change it!!
l = he.split(s,'='); --pprl(l)
assert(l[1] == 'ab')
assert(l[3] == '')
assert(l[4] == '')
l = he.split(s); --pprl(l)
assert (#l == 3 and l[3] == 'f==')
l = he.split(s, nil, 1); 
assert(#l == 2 and l[2]=='de   f==')
l = he.split(s, '=', 2); 
assert(#l == 3 and l[3]=='=')
s =  "a\t\t\r\n\r\t\nbb cc\t\r\rddd\n\n\teee"
l = he.spsplit(s)
assert(#l == 5 and l[3]=="cc" and l[5]=="eee")
-- eolsplit()
s = ""; assert(list.lseq(he.eolsplit(s), {""}))
s = "abc"; assert(list.lseq(he.eolsplit(s), {"abc"}))
s = "abc\n"; assert(list.lseq(he.eolsplit(s), {"abc", ""}))
s = "abc\r\n"; assert(list.lseq(he.eolsplit(s), {"abc", ""}))
s = "\nabc"; assert(list.lseq(he.eolsplit(s), {"", "abc"}))
s = "ab\rc\n"; assert(list.lseq(he.eolsplit(s), {"ab\rc", ""}))
s = "abc\r\ndef"; assert(list.lseq(he.eolsplit(s), {"abc", "def"}))
-- lines() iterator
f = function(s)
	local t = list()
	for l in he.lines(s) do t:insert(l) end
	return t
end
assert(f"":lseq{""})
assert(f"a":lseq{"a"})
assert(f"a\n":lseq{"a"})
assert(f"a\r\n":lseq{"a"})
assert(f"a\n\r":lseq{"a", ""})
assert(f"a\rb\r":lseq{"a", "b"})
assert(f"\na":lseq{"", "a"})
assert(f"\r\na":lseq{"", "a"})
assert(f"\r \na":lseq{"", " ", "a"})

	
-- *strip
s = '\tabc  \r\n  '
assert(he.strip(s) == 'abc') 
assert(he.rstrip(s) == '\tabc')
assert(he.lstrip(s) == 'abc  \r\n  ')
assert(he.lstrip('\r\r\n\na') == 'a')

-- rpad, lpad
assert(he.rpad('abc', 6) == "abc   ")
assert(he.lpad('abc', 6) == "   abc")
assert(he.rpad('abc', 6, '-') == "abc---")
assert(he.lpad('abc', 6, '-') == "---abc")
assert(he.rpad('abcdef', 3) == "abcdef")
assert(he.lpad('abcdef', 3) == "abcdef")




------------------------------------------------------------------------
-- test classes and objects
--	130323 'class' simplification' !!
c = he.class()
function c:init(val)  self.a = val ; return self end
function c:get() return self.a end
x = c():init('hello')
assert(x:get() == 'hello')
assert(getmetatable(x) == c)
assert(getmetatable(c) == he.class)
d = he.class(c)
--
local fifo = he.class()
function fifo:push(x) table.insert(self, 1, x) end
function fifo:pop() return table.remove(self) end
local f = fifo(); f:push(11); f:push(22); assert(f:pop() == 11)

------------------------------------------------------------------------
-- test list functions and list objects

a = {'hello', 22}
b = {'hello', 22} --do not change a and b!!
--contains
assert(list.find(a,22) and not list.find(a,33))
--equal
assert(a ~= b)
assert(he.equal(a, b))
-- extend
list.extend(a, b); assert(a[3] == 'hello')
-- reduce, map*
assert(list.reduce({1,2,3}, function(acc, v) return acc + v end, 0) == 6)
c = list.mapfilter(a, function(x) return type(x) == 'string' and x end)
assert(c[2] == 'hello')
d = list.map(c, function(x) return x..' bob' end)
assert(c[2] == 'hello' and d[2] == 'hello bob')
c = {} --map on empty list
d = list.map(c, function(x) return x..' bob' end)
assert(#d == 0)
d = list.map(c, function(x) return type(x) == 'string' and x end)
assert(#d == 0)
-- table funcs
a = {'a', 'b', 123}
assert(list.concat(a, '') == 'ab123' and list.concat(a, '/') == 'a/b/123')
list.insert(a, 1); assert(a[4]==1)
table.insert(a, 2, 99); assert(a[1]=='a' and a[2]==99 and a[5]==1)
table.remove(a, 2); assert(a[1]=='a' and a[2]=='b')
a = {9,3,5,1}; table.sort(a); assert(he.equal(a, {1,3,5,9}))
a = {}; table.sort(a); assert(he.equal(a, {}))
a = {}; list.insert(a, 11); assert(a[1]==11)
list.insert(a, 22); assert(a[2]==22)
-- find_elem(), check_elems()
a = {9,3,5,1}
assert(list.find_elem(a, function(v) return v==5 end))
assert(list.check_elems(a, function(v) return v<55 end))
assert(not list.find_elem(a, function(x) return type(x)=='string' end))

t = list()
t:insert{key=222, name='vic', age=33}
t:insert{key='u111', name='paul', age=47}
t:insert{key=333, name='mary', age=12}
b = t:mapfilter(function(e) if e.name=='mary' then return e end end)
assert(#b == 1 and b[1].age == 12)
--~ b = t:filter(he.testf, 'name', string.match, '.*a');  
b = t:mapfilter(function(e) return e.name:match'.*a' and e end);  
assert(#b == 2 and b[1].age == 47) 
--~ b = t:sorted(he.reccmp'name') ; assert(#b == 3 and b[3].age == 33)
b = t:mapwhile(function(e) return e.age * 2 end) ; assert(b[3] == 24)

-- test list objects
a = list(); assert(#a == 0)
a = list{}; assert(#a == 0)
a = list{11,33,22}; assert(#a == 3)
b = list()
--~ pp('list', list)
--~ pp('a', a)
for i,v in ipairs(a:sorted()) do 
	b:insert(v) 
end
assert(b:concat('') == "112233")

-- list iterator
f = function(l)
	local li, le = list(), list()
	for i, e in l do le:insert(e); li:insert(i) end
	return li, le
end
local li, le
li, le = f(list{11,22, 33})
assert(li:lseq{1,2,3} and le:lseq{11,22,33})
li, le = f(list{}); assert(li:lseq{} and le:lseq{})


-- test list-based set functions
a = list();  b = a:uniq();  assert(b:equal{})
a = list{11,22,11,11,33,11,22,22}
b = a:uniq();  assert(b:equal{11, 22, 33})
b:uinsert(55) ; b:uinsert(66) ; b:uinsert(66) ; b:uinsert(55) ; 
assert(b:equal{11, 22, 33, 55, 66})
b:uextend{11,11,66,66,11};  assert(b:equal{11, 22, 33, 55, 66})
b:uextend{};  assert(b:equal{11, 22, 33, 55, 66})
a:uremove(22);  assert(a:equal{11,11,11,33,11,22,22})
b:uremove(77);  assert(b:equal{11, 22, 33, 55, 66})


------------------------------------------------------------------------
-- test table functions

-- count
a = {}; assert(he.count(a) == 0)
a.x = 11; a.y = 22; assert(he.count(a) == 2)
assert(he.count(a, function(v) return v>15 end) == 1)
assert(he.count(a, function(v) return list.find({11,22}, v) end) == 2)
assert(he.count(a, function(v) return list.find({22, 'y'}, v) end) == 1)
assert(he.count(a, function(v) return list.find({'a', 'y'}, v) end) == 0)

-- keys, sortedkeys
b = list(); for k,v in pairs(a) do b:insert(k) end
assert(b:find('x') and b:find('y'))
b = list(); for i,k in ipairs(list(he.keys(a))) do b:insert(k) end
assert(b:find('x') and b:find('y'))
b = list(); for i,k in ipairs(he.sortedkeys(a)) do b:insert(k) end
assert(b:concat('') == "xy")
b = list(); for i,k in ipairs(he.sortedkeys(a)) do b:insert(a[k]) end
assert(b:concat('') == "1122")
-- check can sort heterogeneous keys
t = {a=11, [123]=111, xcv=222, [3488]=333}
b = he.sortedkeys(t)
assert(he.equal(b, {123, 3488, 'a', 'xcv'}))

-- incr
t = {}
assert(he.incr(t, 'x') == 1)
assert(he.incr(t, 'x') == 2)
assert(he.incr(t, 'x', 3) == 5)
d = {}; 
d.x=1; assert(d['x'] == 1)
assert(he.incr(d, 'x')==2 and d.x == 2)
d = {x=1, y=2}
assert(he.count(d)==2)
assert(d.x==1 and d.y==2)
assert(he.equal(list.sorted(he.keys(d)), {'x', 'y'}))
assert(he.equal(he.sortedkeys(d), {'x', 'y'}))
assert(he.equal(he.list{'y'}, he.keys(d, function(v) return v==2 end)))
assert(he.count(d, function(v) return v==1 end), 1)
assert(he.count(d, function(v) return v>10 end), 0)

-- update
d = {a=11, b=22};  he.update(d, {c=33, b=99})
assert(he.count(d) == 3 and d.a == 11 and d.b == 99 and d.c == 33)
assert(he.equal(d, he.update(d, {})))
assert(he.equal(d, he.update(d, d)))



------------------------------------------------------------------------
-- test misc functions

-- repr
assert(he.repr(123) == [[123]])
assert(he.repr(123) == [[123]])
assert(he.repr('hello') == [["hello"]])
assert(he.startswith(he.repr{}, '"table: '))
-- clone
t = {x=11, y=22}; u = he.clone(t)
for k,v in pairs(t) do assert(u[k] == v) end 
assert(u ~= v); 
t = {11,22,33}; u = he.clone(t)
for k,v in pairs(t) do assert(u[k] == v) end 
assert(u ~= v)
-- equal
a = {}; b = {};  assert(he.equal(a,b))
a = {}; b = {1};  assert(not he.equal(a,b))
a = {x=11, y=22}; b = {y=22, x=11};  assert(he.equal(a,b))
-- sorted
t = {9,3,27}
assert(list.sorted(t)[2] == 9 and t[2] == 3)
-- n2s
assert(he.ntos(123)=='123')
assert(he.ntos(1234)=='1,234')
assert(he.ntos(1234.668, '%9.2f')=='  1,234.67')

--pattern
assert(he.escape_re('a.b')=='a%.b')


------------------------------------------------------------------------
-- test spack, sunpack serialization functions

do
	--test equality including the metatable
	local function eq(a, b) return he.equal(a, b, true) end
	
	local s, t, u, v, w
	assert(he.sunpack(he.spack( 0 )) == 0 )
	assert(he.sunpack(he.spack( -1 )) == -1 )
	assert(he.sunpack(he.spack( -2 )) == -2 )
	assert(he.sunpack(he.spack( 239 )) == 239 ) --0xef
	assert(he.sunpack(he.spack( 1000 )) == 1000 )
	assert(he.sunpack(he.spack( 1.02 )) == 1.02 )
	assert(he.sunpack(he.spack( "" )) == "" )
	assert(he.sunpack(he.spack( "aaa" )) == "aaa" )
	assert(he.sunpack(he.spack( ('a'):rep(10000))) == ('a'):rep(10000))
	assert(he.sunpack(he.spack( ('a'):rep(1000000))) == ('a'):rep(1000000))
	assert(eq({}, he.sunpack(he.spack( {} ))))
	assert(eq({{{}}}, he.sunpack(he.spack( {{{}}} ))))
	t = {{a={'aaa'}}, 11, 22}
	assert(eq(t, he.sunpack(he.spack( t ))))
	l = he.list{{a={'aaa'}}, 11, 22}
	assert(eq(l, he.sunpack(he.spack( l ))))

	-- regular table literals
	t = {11, 22, name="abc", {}, {{}}, {x=1, y=1.0}}
	s = he.spack(t)
	u = he.sunpack(s)
	assert(eq(t, u))

	t = {11, y=22, list{33,55}}
	s = he.spack(t)
	u = he.sunpack(s)
	assert(eq(t, u))

end


------------------------------------------------------------------------
-- test file and os functions
-- isodate, isots
assert(string.match(he.isodate(),  -- eg. 2009-07-07 13:31:28
			"^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$"))
assert(string.match(he.isots(),  -- eg. 20010908_214640
			"^%d%d%d%d%d%d%d%d_%d%d%d%d%d%d$"))
-- remember test may run in a different TZ 
-- => compare absolute times only in UTC
assert(he.isodate(1000000000, true) == "2001-09-09 01:46:40 UTC")
assert(he.isots(1000000000, true) == "20010909_014640")

x = os.time()

assert(x == he.isototime(he.isodate(x)))
assert(he.isots(he.isototime("20090707T133128")) == "20090707_133128")
assert(he.isots(he.isototime("20090707_133128")) == "20090707_133128")
assert(he.isots(he.isototime("20090707_1331")) == "20090707_133100")
assert(he.isots(he.isototime("2009-07-07 13:31")) == "20090707_133100")
assert(he.isots(he.isototime("20090707")) == "20090707_000000")

------------------------------------------------------------------------
-- test pathname functions

-- basename
assert(he.basename("/") == "/")
assert(he.basename("///") == "/")
assert(he.basename("///", "/") == "/")
assert(he.basename("/de.f") == "de.f")
assert(he.basename("ab/de.f") == "de.f")
assert(he.basename("/ab/de.f") == "de.f")
assert(he.basename("///ab/de.f") == "de.f")
assert(he.basename("///ab/de.f/") == "de.f")
assert(he.basename("/ab/de.f", ".f") == "de")
assert(he.basename("ab.f/de.f", ".f") == "de")
assert(he.basename("ab/de.f", {".g", ".f"}) == "de")
assert(he.basename("ab/de.f", {".g"}) == "de.f")

-- dirname
assert(he.dirname("///") == "/")
assert(he.dirname("///abc") == "/")
assert(he.dirname("///abc/") == "/")
assert(he.dirname("/abc/def") == "/abc")
assert(he.dirname("abc/def") == "abc")
assert(he.dirname("a:/bc") == "a:")
--~ assert(he.dirname("a:/") == "a:/")  -- not supported 

-- fileext
assert(he.fileext("") == "")
assert(he.fileext("///") == "")
assert(he.fileext("/a") == "")
assert(he.fileext("/a.b") == "b")
assert(he.fileext("/def/a.b") == "b")
assert(he.fileext("/de.f/a.b") == "b")
assert(he.fileext("/de.f/a") == "")
assert(he.fileext("/de.f/") == "")

-- isabspath
assert(he.isabspath "/")
assert(he.isabspath "/abc/d")
assert(he.windows and he.isabspath "f:/abc/d" or not he.isabspath "f:/abc/d")
assert(he.windows and he.isabspath "F:/abc/d" or not he.isabspath "F:/abc/d")
assert(not he.isabspath "")
assert(not he.isabspath "abc/d")
assert(not he.isabspath "f:abc/d")

-- wdrive
if he.windows then
	assert(he.wdrive("a:/bc/def/") == "a")
	assert(he.wdrive("A:/bc/def/") == "A")
	assert(he.wdrive("ab:/bc/def/") == nil)
	assert(he.wdrive("/bc/def/") == nil)
end

-- makepath
assert(he.makepath("ab", "cd") == "ab/cd")
assert(he.makepath("/ab/", "cd") == "/ab/cd")
assert(he.makepath("ab", "/cd") == "ab//cd") -- should be nil?

------------------------------------------------------------------------
-- test file and os functions

-- --[==[

local test_tmpdir = he.tmpdir()
local fn = he.makepath(test_tmpdir, 'he_test_file.txt')
--~ print('tmp file path:', fn)
he.fput(fn, 'hello'); x = he.fget(fn); assert(x == 'hello')

-- shell, shlines

-- Platform is Linux
x = he.shell('ls -1 ' .. test_tmpdir .. '/he_test_file.t*')
assert(he.endswith(he.split(x)[1], 'he_test_file.txt'))

os.remove(fn)

print("test_he:	ok")
