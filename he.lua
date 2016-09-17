-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[	he utility module 

content:

  equal			test equality (deep)
  compare_any	compare values with any type 
				(useful to sort heterogeneous lists)

  class			a minimalist class constructor
  list			a simple List class
  
  -- list functions:
  app			append an element (same as table.insert without argument)
  rem			remove an element
  pop			pop last element (same as table.remove without argument)
  join			join all elements into a string (same as table.concat)
  sort			sort a list (same as table.sort)
  sorted		return a sorted copy of a list
  extend		append all the elements of another list 
  filter		select elements that match a predicate
  map			map a function over a list
  has			test if a list contains some value
  find_elem		find an element that matches a predicate
  check_elems	check that all elements match a predicate
  lseq			test equality (shallow)
  elems			iterator over the elements of a list (matching a predicate)
  uniq			return a list with unique elements in a list
  uapp			same as app but ensure all elements are unique
  uextend		same as extend but ensure all elements are unique
  urem			remove first occurence of a value in a list
  
  -- other table functions
  clone			copy a table (shallow copy)
  update		extend a table with the (key, val) from another table
  incr			increment a value in a table (create value if needed)
  collect		append to a list in a table (create list if needed)
  ucollect		same as collect but elements in list are unique
  keys			return table keys
  sortedkeys	return table keys sorted
  count			count elements in a table
  
  -- string functions
  startswith	test if a string starts with  a prefix
  endwith		test if a string ends with  a suffix
  split			split a string on a separator pattern
  rstrip		strip whitespace at beginning
  lstrip		strip whitespace at end
  strip			strip whitespace at beginning and end
  stripeol		strip whitespace at each end of line
  stripnl		strip empty lines at beginning and end
  unix2dos		convert LF to CRLF
  dos2unix		convert CRLF to LF
  escape_re		escape a string so it can be used as a re pattern
  repr			return a string representation of a value
  stohex        return a hexadecimal representation of a binary string
  hextos        parse a hex encoded string, return the string
  ntos			convert a number to a string with a thousand separator ','
  
  --misc OS functions
  isodate		convert time to ISO date representation
  iso2time		parse ISO date and return a time (sec since epoch)
  shell			execute a shell command, return stdout as a string
  shlines		execute a shell command, return stdout as a list of lines
  escape_sh		escape posix shell special chars
  source_line   return the current file and line number
  exitf			write a formatted message and exit from the program
  checkf        check a value. if false, exit with a formatted message
  
  -- misc file and pathname functions
  fget			return the content of a file as a string
  fput			write a string to a file
  fgetlines		return the content of a file as a list of strings
  fputlines		write a list of lines to a file
  pnormw		normalize a path for windows
  pnorm			normalize a path for unix
  tmpdir		returns a temp directory
  ptmp			returns a temp path
  basename		strip directory and suffix from a file path
  dirname       strip last component from file path
  fileext       return the extension of a file path
  is_absolute_path  return true if a path is absolute

  ---
  
  160830
	fixed compare_any, sortedkeys
  160828  
    fixed pp: iterate on all args even if some are nil
	fixed repr: repr(nil) is 'nil', not '"nil"')

]]

local he = {}  -- the he module

he.VERSION = 'he091, 160828'

------------------------------------------------------------------------
table.unpack = table.unpack or unpack  --compat v51/v52
	-- unpack is a global for 5.1 and field of module table for 5.2 
	-- always use table.unpack in he. define it here if needed


------------------------------------------------------------------------
-- compare any Lua values

function he.equal(a, b, checkmt)
	-- test equality between two lua values (deep equality)
	-- beware cycles!! would lead to infinite recursion
	-- userdata values are not compared (for them, equal is ==)
	-- if checkmt is true, metatables are also compared 
	-- default is to ignore metatables
	if a == b then return true end
	local ta, tb = type(a), type(b)
	if ta ~= tb then return false end
	if ta == 'table' then
		if checkmt and (getmetatable(a) ~= getmetatable(b)) then
			return false
		end
		local cnta, cntb = 0, 0
		for k,v in	 pairs(a) do 
			cnta = cnta + 1
			if not he.equal(v, b[k]) then return false end
		end
		-- here, all elem in a have equal elems in b. now,
		-- must check b has no more elems (# doesnt work)
		for k,v in pairs(b) do cntb = cntb+ 1 end
--~		 print(cnta, cntb)
		return cnta == cntb
	else return false 
	end
end

function he.compare_any(x, y)
	-- compare data with any type (useful to sort heterogeneous lists)
	-- equivalent to x < y for same type data
	-- order: nil < any number < any string < any other object
	local tx, ty = type(x), type(y)
	if tx == ty then 
		if tx == 'string' or tx == 'number' then return x < y 
		else return true -- ignore order on tables and others
		end
	end
	if x == nil  then return true end
	if y == nil  then return  false end
	if tx == 'number' then return true end
	if tx == 'string' then return ty ~= 'number' end
	if ty == 'string' then return false end
	return true
end



------------------------------------------------------------------------
-- class 
-- ... a minimalist "class" concept!
-- ... just a way to associate methods to tables. 
-- ... no inheritance, no information hiding, no initialization!
--
-- to create a class c, use:  c = class() 
-- to create an instance of c, use:  obj = c()  or  obj = c{x=1, y=2}
--   constructor argument must be nil 
--   or a table _which becomes the object_
--
local class = { } ; he.class = class

setmetatable(class, class)

function class.__call(c, t)
	-- if t is an object with a metatable mt, mt will be replaced.
	local obj = setmetatable(t or {}, c)
	if c == class then obj.__index = obj end 
	return obj
end


------------------------------------------------------------------------
-- list and list functions

local list = he.class() ;  he.list = list

local app = function(t, elem) t[#t+1] = elem ; return t end
local rem = function(t, i) table.remove(t, i); return t end
local pop = table.remove
local join = table.concat

list.app, list.rem, list.pop, list.join = app, rem, pop, join
list.equal, list.sort = he.equal, table.sort

function list.extend(lst, otherlist)
	-- extend list with otherlist
	local e = #lst
	for i,v in ipairs(otherlist) do lst[e+i] = v end
	return lst
end

function list.filter(lst, pred, ...)
	-- return a shallow copy of lst with elems e where pred(e, ...) is true
	local t2 = list()
	for k, e in ipairs(lst) do if pred(e, ...) then app(t2, e)  end end
	return t2
end

function list.sorted(lst, cmpf)
	-- returns a sorted shallow copy of lst
	-- l:sorted(cmpf):  use f as a compare function
	--	cmpf(e1, e2) replaces e1 < e2
	local el = list()
	for i,e in ipairs(lst) do app(el, e) end
	table.sort(el, cmpf)
	return el
end --sorted()

function list.map(lst, f, ...)
	-- maps function f over list lst
	-- f(v, ...) is applied to each element v of lst, in sequence
	-- creates a new list with results of f (v, ...) 
	--		(only if result is non false)
	--		(=> cannot be used to make a list with false elems...)
	assert(f)
	local r = list()
	local x
	for i, v in ipairs(lst) do
		if f then x = f(v, ...) else x = v end
		if x then app(r, x) end
	end
	return r
end

function list.lseq(lst, lst2)
	-- "list simple (or shallow) equal" - compare list/array portion of tables
	--  (uses '==' for comparison --ie identity-- for tables. does not recurse)
	if #lst ~= #lst2 then return false end
	for i = 1, #lst do 
		if lst[i] ~= lst2[i] then return false end 
	end
	return true
end

function list.has(lst, elem)
	for i,v in ipairs(lst) do 
		if v == elem then return true end 
	end
	return false
end

function list.find_elem(lst, pred, ...)
	-- returns an elem e for which pred(e) is true, or nil if none
	for i,e in ipairs(lst) do 
		if pred(e, ...) then return e end 
	end
	return nil
end

function list.check_elems(lst, pred, ...)
	-- return true if pred(e) is true for all elems e in list
	for i,e in ipairs(lst) do 
		if not pred(e, ...) then return false end 
	end
	return true
end

--[[
local inext = ipairs({}) 
	-- equivalent to next() for pairs() - still valid with 5.2?!?
]]

function list.elems(lst, pred, arg1, arg2, arg3)
	-- iterator over all lst elements
	--	for e in lst:elems() do ...
	-- or for e in lst:elems(he.isgt, 20) do ...
	local i = 1
	if pred then
		return function()
			local e = lst[i]
			while e and not pred(e, arg1, arg2, arg3) do
				i = i +1;  e = lst[i]
			end--while
			return e
		end --function
	else
		return function() local e = lst[i]; i = i +1; return e  end
	end--if
end--elems()

--
-- list-based set functions
--
function list.uniq(lst)
	-- return a list of unique elements in lst (named after unix's uniq)
	local t = {}
	local ul = list()
	for i,e in ipairs(lst) do
		if not t[e] then
			app(ul, e)
			t[e] = true
		end
	end
	return ul
end

function list.uapp(lst, e)
	-- set insert:  append an element only if it is not already in list
	for i,x in ipairs(lst) do if e == x then return end end
	return app(lst, e)
end

function list.uextend(lst, l2)
	-- set extend:  set insert all elements of l2 in lst 
	--   (ie insert only unique elements)
	--   if lst is a list-based set, after uextend,  lst is still a set.
--~	 local ul2 = list.uniq(l2) --not needed if use uapp()
	for i, x in ipairs(l2) do list.uapp(lst, x) end
	return lst
end

function list.urem(lst, e)
	-- remove 1st occurence of e in lst (set remove for a list-based set)
	local ei
	for i,x in ipairs(lst) do
		if e == x then  ei = i;  break  end
	end
	if ei then table.remove(lst, ei) end
	return lst
end


------------------------------------------------------------------------
-- other useful table functions


function he.clone(t)
	-- create a copy of table
	-- (this is a shallow clone - no deep copy)
	local ct = {}
	for k,v in pairs(t) do ct[k] = v end
	setmetatable(ct, getmetatable(t))
	return ct
end

function he.update(t, t2)
	-- append all k,v pairs in table t2 to table t
	-- (if k already exists in t, t[k] is overwritten with t2[k])
	-- return t
	for k,v in pairs(t2) do t[k] = v end
	return t
end

function he.incr(t, k, n)
	-- incr t[k] by n (if no n, incr by 1)
	-- if no t[k], create one with init value=0, then incr.
	local v = (t[k] or 0) + (n or 1)
	t[k] = v
	return v
end

function he.collect(t, k, e)
	-- appends e to list t[k]
	-- creates list if t[k] doesnt exist.
	if not t[k] then t[k] = list() end
	app(t[k], e)
end

function he.ucollect(t, k, e)
	-- appends e to list-based set t[k] if not already in there.  
	-- creates list if t[k] doesnt exist.
	if not t[k] then t[k] = list() end
	list.uapp(t[k], e)
end

function he.keys(t, pred, ...) 
	-- returns list of keys of t
	-- if predicate, returns only keys for which pred(v, ...) is true
	local kt = list()
	for k,v in pairs(t) do 
		if not pred or pred(v, ...) then app(kt, k) end 
	end
	return kt  
end

function he.sortedkeys(t, pred, ...)  
	-- returns sorted list of keys of t
	-- if predicate is defined, return only keys for which pred(v, ...) is true
	-- sort works with heterogeneous keys (use compare_any) 
	--   in case of performance issue, simply use sorted(keys(. . .)) )
	local kt = he.keys(t, pred, ...); 
	table.sort(kt, he.compare_any); 
	return kt 
end

function he.count(t, pred, ...)  
	-- returns number of keys in table t
	-- if pred, count only keys for which pred(v, ...) is true
	local n = 0
	if pred then 
		for k,v in pairs(t) do if pred(v, ...) then  n = n + 1 end end
	else
		for k,v in pairs(t) do n = n + 1 end
	end--if pred
	return n
end

------------------------------------------------------------------------
-- string functions

he.strf = string.format

function he.startswith(s, px)
	-- test if a string starts with  a prefix.
	-- px is either a string or a list of strings (can be a raw table)
	-- if px is a list, each string in list is tested until one matches
	-- prefixes are plain strings, not regular expressions
	-- returns the matching prefix or nil
	if type(px) == "string" then 
		return (string.find(s, px, 1, true) == 1) and px or nil
	else -- assume px is a list of prefix
		for i, p in ipairs(px) do 
			if string.find(s, p, 1, true) == 1 then return p end
		end
	end--if
end--startswith

function he.endswith(s, sx)
	-- test if a string ends with  a suffix.
	-- sx is either a string or a list of strings (can be a raw table)
	-- if sx is a list, each string in list is tested until one matches
	-- suffixes are plain strings, not regular expressions
	-- returns the matching suffix or nil
	if type(sx) == "string" then 
		local j = #s - #sx + 1
		return (string.find(s, sx, j, true) == j) and sx or nil
	else -- assume sx is a list of suffix
		for i, su in ipairs(sx) do 
			local j = #s - #su + 1
			if string.find(s, su, j, true) == j then return su end
		end
	end--if
end--endswith

function he.split(s, sep, cnt)
	-- sep: split on sep, defaults to whitespaces (a la py)
	-- !! sep is a regexp => escape special chars !!
	-- !! to escape a spe-char, use '%<spe-char>' (NOT '\'!!)
	-- !! eg. to split s on a dot: split(s, '%.')
	-- cnt: optional number of split (default to all)
	sep = sep or "%s+"
	cnt = cnt or -1
	local t = he.list(); local i0 = 1; local i,j  
	local find, sub = string.find, string.sub
	while i0 do
		i,j = find(s, sep, i0)
		if i and (cnt ~= 0) then 
			app(t, sub(s, i0, i-1))
			i0 = j + 1 ;  cnt = cnt - 1
		else break end --if
	end --while
	app(t, sub(s, i0, -1))
	return t
end --split()

function he.lines(s) return he.split(s, '\r?\n') end

function he.lstrip(s)
	-- remove whitespace at beginning of string s
	return string.gsub(s, '^%s+', '') 
end

function he.rstrip(s) 
	-- remove whitespace at end of string s
	return string.gsub(s, '%s+$', '') 
end

function he.strip(s) 
	-- remove whitespace at both ends of string s
	return he.lstrip(he.rstrip(s)) 
end

function he.stripeol(s) 
	-- remove whitespace at end of each line in string s
	return string.gsub(he.rstrip(s), '%s+(\r?\n)', '%1') 
end

function he.stripnl(s)
	-- strip empty lines at beginning and end of string s
	s = string.gsub(s, '^[\r\n]+', '')
	s = string.gsub(s, '[\r\n]+$', '')
	return s
end

function he.unix2dos(s)
	-- change all end of lines in string s to CRLF
	-- returned updated string
	s = s:gsub('\r\n', '\n')
	s = s:gsub('\n', '\r\n')
	return s
end

function he.dos2unix(s)
	-- change all end of lines in string s to LF
	-- returned updated string
	s = s:gsub('\r\n', '\n')
	return s
end

function he.escape_re(s)
	-- escapes string s so it can be used as a re pattern
	-- eg.  he.escape_re("a.b") -> "a%.b"
	return string.gsub(s, "(%p)", "%%%1")
end

------------------------------------------------------------------------
-- string representations

function he.repr(x) 
	if type(x) == 'number' or type(x) == 'boolean' or type(x) == 'nil' then
		return tostring(x)
	else
		return string.format("%q", tostring(x)) 
	end
end

-- hex representation of binary strings

function he.stohex(s, ln, sep)
	-- stohex(s [, ln [, sep]])
	-- return the hex encoding of string s
	-- ln: (optional) a newline is inserted after 'ln' bytes 
	--	ie. after 2*ln hex digits. Defaults to no newlines.
	-- sep: (optional) separator between bytes in the encoded string
	--	defaults to nothing (if ln is nil, sep is ignored)
	-- example: 
	--	stohex('abcdef', 4, ":") => '61:62:63:64\n65:66'
	--	stohex('abcdef') => '616263646566'
	--
	local strf, byte = string.format, string.byte
	if #s == 0 then return "" end
	if not ln then -- no newline, no separator: do it the fast way!
		return (s:gsub('.', 
			function(c) return strf('%02x', byte(c)) end
			))
	end
	sep = sep or "" -- optional separator between each byte
	local t = {}
	for i = 1, #s - 1 do
		t[#t + 1] = strf("%02x%s", s:byte(i),
				(i % ln == 0) and '\n' or sep) 
	end
	-- last byte, without any sep appended
	t[#t + 1] = strf("%02x", s:byte(#s))
	return table.concat(t)	
end --stohex()

function he.hextos(hs, unsafe)
	-- decode an hex encoded string. return the decoded string
	-- if optional parameter unsafe is defined, assume the hex
	-- string is well formed (no checks, no whitespace removal).
	-- Default is to remove white spaces (incl newlines)
	-- and check that the hex string is well formed
	local tonumber, char = tonumber, string.char
	if not unsafe then
		hs = string.gsub(hs, "%s+", "") -- remove whitespaces
		if string.find(hs, '[^0-9A-Za-z]') or #hs % 2 ~= 0 then
			error("invalid hex string")
		end
	end
	return (hs:gsub(	'(%x%x)', 
		function(c) return char(tonumber(c, 16)) end
		))
end -- hextos


function he.ntos(n, nf)
	-- "number to string"
	-- represent number n as a string with a thousand separator (',')
	-- use optional printf format 'nf' (default is %d)
	-- eg. ntos(12345) -> "12,345",  
	-- with Lua 5.3, if n is not an integer, default format '%.2f' is used
	-- eg. ntos(1234.5) -> "1,234.50"
	
	if _VERSION=="Lua 5.3" and math.type(n)=="float" then 
		nf = nf or "%.2f" 
	else
		nf = nf or "%d"
	end 
	local s = string.format(nf, n)
	local t = he.split(s, '%.'); s = t[1]
	s, n = string.gsub(s, '(%d)(%d%d%d)$', '%1,%2')
	while n > 0 do
		s, n = string.gsub(s, '(%d)(%d%d%d),', '%1,%2,')
	end
	t[1] = s
	return join(t, '.')  
end


------------------------------------------------------------------------
-- date functions



function he.isodate(t)	 -- format: 20090709T122122
	return os.date("%Y%m%dT%H%M%S", t) 
end

function he.isodate19(t)	 -- format: 2009-07-09 12:21:22
	return os.date("%Y-%m-%d %H:%M:%S", t) 
end

function he.isodate11(t)	 -- format: 090709_1221
	return os.date("%y%m%d_%H%M", t) 
end

function he.iso2time(s)
	-- parse an iso date - return a time (seconds since epoch)
	-- format: 20090709T122122 or 20090709T1234 or or 20090709
	-- (missing sec, min, hrs are replaced with '00')
	-- (T can be replaced with '-' or '_')
	local t = {}
	t.year, t.month, t.day, t.hour, t.min, t.sec = string.match(s, 
		"(%d%d%d%d)(%d%d)(%d%d)[T_-](%d%d)(%d%d)(%d%d)")
	if t.year then return os.time(t) end
	t.year, t.month, t.day, t.hour, t.min = string.match(s, 
		"(%d%d%d%d)(%d%d)(%d%d)[T_-](%d%d)(%d%d)")
	if t.year then t.sec = '00'; return os.time(t) end
	t.year, t.month, t.day = string.match(s, "(%d%d%d%d)(%d%d)(%d%d)")
	if t.year then 
		t.hour = '00'; t.min = '00'; t.sec = '00'; return os.time(t)
	end
	return nil, "he.iso2time: invalid format"
end

------------------------------------------------------------------------
-- file functions

function he.fget(fname)
	-- return content of file 'fname'
	local f = assert(io.open(fname, 'rb'))
	local s = f:read("*a") ;  f:close()
	return s
end

function he.fput(fname, content)
	-- write 'content' to file 'fname'
	local f = assert(io.open(fname, 'wb'))
	assert(f:write(content) ); 
	assert(f:flush()) ; f:close()
end

function he.fgetlines(fname)
	-- return content of file 'fname' as a list of lines
	local sl = list()
	for s in io.lines(fname) do sl[#sl + 1] = s end
	return sl
end

function he.fputlines(fname, sl, eol)
	-- write all lines in sl to file 'fname'
	-- sl is a list of strings (with no eol)
	-- put eol between strings (not at end). default is \n.
	eol = eol or '\n'
	local f = io.open(fname, "w")
	local content = table.concat(sl, eol)
	f:write(content)
	f:flush()
	f:close()
end

------------------------------------------------------------------------
-- OS / shell functions

function he.shell(cmd)
	-- execute cmd; return stdout as a string and a status code.
	-- the status code is the exit code, or if the program has been 
	-- interrupted by a signal, 1000 + the signal number
	-- [convention for most shells is 128+N, ksh93 is 256+N so maybe 
	--  1000+N is a bit exotic...but easy to read]
	local f = io.popen(cmd) 
	local s = f:read("*a")
	-- close on a popen returns the same values as os.execute()
	-- success, exit type (exit or signal), exit code or signal number
	local succ, exit, status = f:close()
	-- return convention: 
	-- if exit=='signal', return 1000 + signal number
	-- (it allows to return only one status code and test easily.
	-- - exit codes should be below 256)
	-- return s even in case of failure. it allows to get stderr
	-- with a redirection, eg.: s, 
	return s, (exit=='signal' and status+1000 or status)
end

function he.shlines(cmd) 
	-- executes cmd, return stdout as a list of lines
	-- (remove empty lines at beginning and end of cmd output)
	local s, status = he.shell(cmd)
	return s and he.lines(he.stripnl(he.shell(cmd))), status
end

function he.escape_sh(s)  
	-- escape posix shell special chars: [ ] ( ) ' " \
	-- (works for unix, not windows...)
	return string.gsub(s, "([ %(%)%\\%[%]\"'])", "\\%1")
end

------------------------------------------------------------------------
-- small windows/unix dependant definitions
--
he.pathsep = string.sub(package.config, 1, 1)  -- path separator
he.windows = ( string.byte(he.pathsep) == 92)  -- 92 is '\' 
	-- beware cygwin!!  pathsep == '/'.  
	-- is it considered as windows or linux?
	
he.newline = he.windows and '\r\n' or '\n'

function he.tmpdir()
	return he.windows and he.pnorm(os.getenv('TMP')) 
		or os.getenv('TMP') or '/tmp'
end

function he.ptmp(name) 
	-- generate a tmp file path from a name
	-- return a tmp path - eg on unix,  he.ptmp('xyz') -> /tmp/xyz
	return he.tmpdir() .. '/' .. name
end

-- pathname functions

function he.pnormw(p)
	-- normalize a path for windows
	local np = string.gsub(p, '/', '\\')
	-- (keep 'local np =...' to ensure that only one value is returned)
	return np
end

function he.pnorm(p)
	-- normalize a path (default is unix)
	local np = string.gsub(p, '%\\', '/')
	-- (keep 'local np =...' to ensure that only one value is returned)
	return np
end

local function striprsep(p) 
	-- remove sep at end of path
	if p:match('^%a:/$') or p:match('^/$') then return p end
	return p:gsub('/$', '') 
end

function he.basename(path, suffix)
	-- works like unix basename.  
	-- if path ends with suffix, it is removed
	-- if suffix is a list, then first matching suffix in list is removed
	if path:match("^/+$") then return "/" end -- this is gnu basename!
	path = striprsep(path)
	path = path:gsub('^/+', '')
	local dir, base = path:match("^(.+)/(.*)/?$")
	if not base then base = path end
	if not suffix then return base end
	suffix = he.endswith(base, suffix)
	if suffix then return string.sub(base, 1, #base - #suffix ) end
	return base
end

function he.dirname(path)
	-- works like unix dirname.  
	-- (this assume that path is a unix path - separator is '/')
	path = striprsep(path)
	if path:match("^/+[^/]*$") then return "/" end
	return path:match("^(.+)/.*$") or "."
end

function he.fileext(path)
	-- return path extension (or empty string if none)
	-- (this assume that path is a unix path - separator is '/')
	-- note: when a filename starts with '.' it is not considered 
	--    as an extension
	local base = path:match("^.+/(.*)$") or path
	return base:match("^.+%.(.*)$") or ""
end

function he.is_absolute_path(path)
	-- return true if p is an absolute path
	-- either '/something' or 'a:/something'
	return path:match('^%a:/') or path:match('^/')
end

function he.source_line(level)
	-- return <sourcefilename>:<current line>
	-- level is the caller level: 
	--    2: where source_line() is called (this is the default)
	--    3: where the caller of source_line() is called
	--    etc.
	level = level or 2
	local info = debug.getinfo(level) 
	if not info then return "[nil]:-1" end
	local line = string.format("%s:%s", 
		info.short_src, info.currentline)
--~ 		hefs.fname(info.short_src), info.currentline)
	return line
end

function he.exitf(exitcode, fmt, ...)
	-- write a formatted message to stderr and exit the current program 
	-- exitcode is an integer (parameter for os.exit())
	io.stderr:write(string.format(fmt, ...), "\n")
	os.exit(exitcode)
end

function he.checkf(val, fmt, ...)
	-- exit with a formatted message if val is false (exit code is 1)
	-- or return val
	if not val then exitf(1, fmt, ...) end
	return val
end

------------------------------------------------------------------------
-- convenience functions for interactive usage or quick throw-away scripts
-- (used to be in hei.lua)


-- simplistic serialization functions (list to string, table to string)
-- (convenient for debug display or limited use)

function he.l2s(t)
	-- returns list t as a string 
	-- (an evaluable lua list, at least for bool, str and numbers)
	-- !!  beware:  elements of type table are treated by t2s()  !!
	local rl = {}
	local repr, app, join = he.repr, he.list.app, he.list.join
	for i, v in ipairs(t) do 
		app(rl, (type(v) == "table") and he.t2s(v) or repr(v))
	end
	return '{' .. join(rl, ', ') .. '}'
end

function he.t2s(t)
	-- return table t as a string 
	-- (an evaluable lua table, at least for bool, str and numbers)
	-- (!!cycles are not detected!!)
	local repr, app, join = he.repr, he.list.app, he.list.join
	if type(t) ~= "table" then return repr(t) end
	if getmetatable(t) == he.list then return he.l2s(t)  end
	local rl = {}
	-- pairs() is no longer deterministic: several runs on same table
	-- return elements in different order...  (lua 5.3?)
	for i, k in ipairs(he.sortedkeys(t)) do 
		app(rl, '[' .. repr(k) .. ']=' .. he.t2s(t[k])) 
	end
	return '{' .. join(rl, ', ') .. '}'
end


------------------------------------------------------------------------
-- display / debug functions

-- display any object

function he.pp(...)
	local repr = he.repr
	for i = 1, select('#', ...) do
		x = select(i, ...)
		if type(x) == 'table' then 
			he.printf("pp: %s   metatable: %s",  
						tostring(x), tostring(getmetatable(x)))						
			local kl = he.sortedkeys(x)
			for i,k in ipairs(kl) do
				he.printf("	| %s:  %s", repr(k), repr(x[k]))
			end
		else he.printf("pp: %s", he.repr(x))
		end
	end
end

function he.ppl(lst)  print(he.l2s(lst)) end
function he.ppt(lst)  print(he.t2s(lst)) end
function he.ppk(dic)  print(he.l2s(he.sortedkeys(dic))) end

function he.printf(...) print(string.format(...)) end
function he.errf(...) error(string.format(...)) end

--
--~ he.prsep_ch = '-'  -- character used for separator line
--~ he.prsep_ln = 60  -- length of separator line
--~ --
--~ function he.prsep(...) 
--~ --- print a separator line, then print arguments
--~ 	print(string.rep(he.prsep_ch, he.prsep_ln)) 
--~ 	if select('#', ...) > 0  then  print(...)  end
--~ end

------------------------------------------------------------------------
-- elapsed time -- is os.clock() measuring elapsed or cpu time? keep it?

local _hei_load_clock = os.clock()
local _hei_load_time = os.time()

function he.elapsed()
	-- return elapsed time since 'he' was loaded (in seconds)
	-- and cpu time ... or whatever os.clock() refers to :-)
	return (os.time() - _hei_load_time), (os.clock() - _hei_load_clock)
end


function he.print_elapsed(msg) 
-- display elapsed time
	local duration, cpu = he.elapsed()
	print(msg or 'Elapsed:', duration, cpu)  
end

------------------------------------------------------------------------
-- extend environment

function he.extend_string()
	-- extend string module with he string functions
	string.startswith  =  he.startswith
	string.endswith  =  he.endswith
	string.split  =  he.split
	string.lines = he.lines
	string.lstrip  =  he.lstrip
	string.rstrip  =  he.rstrip
	string.strip  =  he.strip
	string.stripnl  =  he.stripnl
	string.stripeol  =  he.stripeol
	string.repr  =  he.repr
	string.stohex  =  he.stohex
	string.hextos  =  he.hextos
end

function he.interactive()
	he.extend_string()
	-- export he to global env
	_G.he = nil
	_G.he = he
	-- export some he defs to global env
	_G.pp, _G.ppl, _G.ppt = he.pp, he.ppl, he.ppt
	_G.strf, _G.printf = string.format, he.printf
	_G.list = he.list
	print(he.VERSION)
	return he
end


------------------------------------------------------------------------
return he 

