-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[

=== test_he


]]

local he = require 'he'
assert(he)

-- make sure we test the correct version
assert(he.VERSION:match("^he096,"), "bad he version")

-- check that _G and string are not extended
assert(not _G.he)
assert(not string.split)

-- some local defs for all the tests
local list = he.list
local pp, ppl, ppt = he.pp, he.ppl, he.ppt
--
local a, b, c, d, f, k, l, s, t, u, v, x, y

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
s = '\tabc  \r\n  '
assert(he.strip(s) == 'abc') 
assert(he.rstrip(s) == '\tabc')
assert(he.lstrip(s) == 'abc  \r\n  ')
assert(he.lstrip('\r\r\n\na') == 'a')


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
assert(list.has(a,22) and not list.has(a,33))
--equal
assert(a ~= b)
assert(he.equal(a, b))
-- extend
list.extend(a, b); assert(a[3] == 'hello')
--filter, map
c = list.map(a, function(x) return type(x) == 'string' and x end)
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
-- any_elem, all_elems
a = {9,3,5,1}
assert(list.find_elem(a, function(v) return v==5 end))
assert(list.check_elems(a, function(v) return v<55 end))
assert(not list.find_elem(a, function(x) return type(x)=='string' end))

t = list()
t:insert{key=222, name='vic', age=33}
t:insert{key='u111', name='paul', age=47}
t:insert{key=333, name='mary', age=12}
b = t:filter(function(e) return e.name=='mary' end)
assert(#b == 1 and b[1].age == 12)
--~ b = t:filter(he.testf, 'name', string.match, '.*a');  
b = t:filter(function(e) return e.name:match'.*a' end);  
assert(#b == 2 and b[1].age == 47) 
--~ b = t:sorted(he.reccmp'name') ; assert(#b == 3 and b[3].age == 33)
b = t:map(function(e) return e.age * 2 end) ; assert(b[3] == 24)

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

-- l2s, t2s
l = {1,2}
d = {a=11, b='bb'}
assert(he.l2s(l) == "{1, 2}")
assert(he.t2s(d) == '{["a"]=11, ["b"]="bb"}')


------------------------------------------------------------------------
-- test table functions

-- count
a = {}; assert(he.count(a) == 0)
a.x = 11; a.y = 22; assert(he.count(a) == 2)
assert(he.count(a, function(v) return v>15 end) == 1)
assert(he.count(a, function(v) return list.has({11,22}, v) end) == 2)
assert(he.count(a, function(v) return list.has({22, 'y'}, v) end) == 1)
assert(he.count(a, function(v) return list.has({'a', 'y'}, v) end) == 0)

-- keys, sortedkeys
b = list(); for k,v in pairs(a) do b:insert(k) end
assert(b:has('x') and b:has('y'))
b = list(); for i,k in ipairs(list(he.keys(a))) do b:insert(k) end
assert(b:has('x') and b:has('y'))
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
--shescape -- esc [ ] ( ) ' " \  and sp
assert(he.escape_sh([[a=("b")]])==[[a=\(\"b\"\)]])
assert(he.escape_sh([[a ['b']\]])==[[a\ \[\'b\'\]\\]])

------------------------------------------------------------------------
-- test file and os functions
-- isodate, isodate11
assert(string.match(he.isodate(),  -- eg. 20090707T133128
			"^%d%d%d%d%d%d%d%dT%d%d%d%d%d%d$"))
assert(string.match(he.isodate19(),  -- eg. 2009-07-07 13:31:28
			"^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$"))
assert(string.match(he.isodate11(), 
			"^%d%d%d%d%d%d_%d%d%d%d$"))
x = os.time()
assert(x == he.iso2time(he.isodate(x)))
assert(he.startswith(he.isodate(x), "20" .. he.isodate11(x):gsub('_', 'T')))

assert(he.isodate(he.iso2time("20090707T133128")) == "20090707T133128")
assert(he.isodate(he.iso2time("20090707_133128")) == "20090707T133128")
assert(he.isodate(he.iso2time("20090707_1331")) == "20090707T133100")
assert(he.isodate(he.iso2time("20090707-1331")) == "20090707T133100")
assert(he.isodate(he.iso2time("20090707")) == "20090707T000000")

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
local fn = he.ptmp('he_test_file.txt')
--~ print('tmp file path:', fn)
he.fput(fn, 'hello'); x = he.fget(fn); assert(x == 'hello')

-- shell, shlines
if he.windows then
--	print('Platform is Windows.')
	x = he.shell('dir /B ' .. he.pnormw(test_tmpdir) .. '\\he_test_file.t*')
	assert(he.endswith(he.split(x)[1], 'he_test_file.txt'))
	x = he.shlines('dir /B ' .. he.pnormw(test_tmpdir) .. '\\he_test_file.t*')
	assert(he.endswith(x[1], 'he_test_file.txt'))
else -- assume linux
--	 print('Platform is Linux.')
	x = he.shell('ls -1 ' .. test_tmpdir .. '/he_test_file.t*')
	assert(he.endswith(he.split(x)[1], 'he_test_file.txt'))
	x = he.shlines('ls -1 ' .. test_tmpdir .. '/he_test_file.t*')
	assert(he.endswith(x[1], 'he_test_file.txt'))
end -- if 

os.remove(fn)



