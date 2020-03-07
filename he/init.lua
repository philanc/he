-- Copyright (c) 2020  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[	

=== he utility module 

content:

  equal         test equality (deep)
  cmpany        compare values with any type 
                (useful to sort heterogeneous lists)

  class         a minimalist class constructor
  list          a simple List class
  
  -- list functions:
  insert        insert or append an element (same as table.insert)
  remove        remove an element (same as table.remove)
  pop           (same as table.remove)
  concat        join all elements into a string (same as table.concat)
  sort          sort a list (same as table.sort)
  sorted        return a sorted copy of a list
  extend        append all the elements of another list 
  filter        select elements that match a predicate
  map           map a function over a list
  has           test if a list contains some value
  find_elem     find an element that matches a predicate
  check_elems   check that all elements match a predicate
  lseq          test equality (shallow)
  elems         iterator over the elements of a list (matching a predicate)
  uniq          return a list with unique elements in a list
  uinsert       same as insert but ensure all elements are unique
  uextend       same as extend but ensure all elements are unique
  uremove       remove first occurence of a value in a list
  

  -- other table functions
  clone         copy a table (shallow copy)
  update        extend a table with the (key, val) from another table
  incr          increment a value in a table (create value if needed)
  collect       append to a list in a table (create list if needed)
  ucollect      same as collect but elements in list are unique
  keys          return table keys
  sortedkeys    return table keys sorted
  count         count elements in a table
  
  -- string functions
  startswith    test if a string starts with  a prefix
  endwith       test if a string ends with  a suffix
  lpad          pad a string on the left
  rpad          pad a string on the right
  split         split a string on a separator pattern
  spsplit       split a string by whitespaces (sp, tab, cr, lf) 
  eolsplit      split a string in lines
  lines         an iterator delivering all the lines in a string
  rstrip        strip whitespace at beginning
  lstrip        strip whitespace at end
  strip         strip whitespace at beginning and end
  stripeol      strip whitespace at each end of line
  stripnl       strip empty lines at beginning and end
  unix2dos      convert LF to CRLF
  dos2unix      convert CRLF to LF
  escape_re     escape a string so it can be used as a re pattern
  repr          return a string representation of a value
  stohex        return a hexadecimal representation of a binary string
  hextos        parse a hex encoded string, return the string
  ntos          convert a number to a string with a thousand separator ','
  
  --misc OS functions
  isodate       convert time to ISO date representation
  iso2time      parse ISO date and return a time (sec since epoch)
  shell         execute a shell command, return stdout as a string
  source_line   return the current file and line number
  exitf         write a formatted message and exit from the program
  checkf        check a value. if false, exit with a formatted message
  
  -- misc file and pathname functions
  fget          return the content of a file as a string
  fput          write a string to a file
  tmpdir        returns a temp directory path
  tmppath       returns a temp path
  basename      strip directory and suffix from a file path
  dirname       strip last component from file path
  fileext       return the extension of a file path
  makepath      concatenate a directory name and a file name
  isabspath     return true if a path is absolute

  ---
  

]]

local he = {}  -- the he module

he.VERSION = 'he106, 200306'

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

function he.cmpany(x, y)
	-- compare data with any type (useful to sort heterogeneous lists)
	-- equivalent to x < y for same type data
	-- order: any number < any string < any other object
	local r
	local tx, ty = type(x), type(y)
	if (tx == ty) and (tx == 'string' or tx == 'number') then r = x < y
	elseif tx == 'number' then r = true
	elseif tx == 'string' then r = (ty ~= 'number')
	elseif ty == 'string' then r = false
	else r = tostring(x) < tostring(y) 
	end--if
	return r
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

-- classes defined in this module:
local list = class() -- see methods below

------------------------------------------------------------------------
-- list and list functions

he.list = list

list.equal = he.equal

list.insert = table.insert
list.remove = table.remove
list.pop = table.remove      -- alias

list.sort = table.sort
list.concat = table.concat


function list.extend(lst, otherlist)
	-- extend list with otherlist
	local e = #lst
	for i,v in ipairs(otherlist) do lst[e+i] = v end
	return lst
end

function list.map(lst, f, ...)
	-- maps function f over list lst
	-- f is applied to each element v of lst, in sequence
	-- creates a new list with results of f(v, ...) 
	-- if the result of f(v, ...) is false, error_msg 
	-- then map() stops and return false, error_msg, part_rlst
	-- where part_rlst is the list of results already collected.
	-- (if f returns false for a value in lst at index i, 
	--  then #part_rlst == i - 1)
	--
	local r = list()
	local x, errmsg
	for i, v in ipairs(lst) do
		x, errmsg = f(v, ...)
		if not x then 
			return false, errmsg, r
		else
			list.insert(r, x) 
		end
	end
	return r
end


function list.mapall(lst, f, ...)
	-- maps function f over list lst
	-- f(v, ...) is applied to each element v of lst, in sequence
	-- creates a new list with results of f (v, ...) 
	-- if f() result is falsy (false or nil), false is inserted
	-- (so #mapall(lst, f, ...) == #lst)
	local r = list()
	local x
	for i, v in ipairs(lst) do
		x = f(v, ...)
		if x then list.insert(r, x) 
		else list.insert(r, false)
		end
	end
	return r
end

function list.mapf(lst, f, ...)
	-- maps function f over list lst  ("map-filter")
	-- f is applied to each element v of lst, in sequence
	-- creates a new list with results of f(v, ...) 
	-- if the result of f(v, ...) is false, it is not inserted.
	--	(=> cannot be used to make a list with false elems...)
	local r = list()
	local x
	for i, v in ipairs(lst) do
		x = f(v, ...)
		if x then list.insert(r, x) end
	end
	return r
end

function list.sorted(lst, cmpf)
	-- returns a sorted shallow copy of lst
	-- l:sorted(cmpf):  use f as a compare function
	--	cmpf(e1, e2) replaces e1 < e2
	local el = list()
	for i,e in ipairs(lst) do table.insert(el, e) end
	table.sort(el, cmpf)
	return el
end --sorted()


function list.lseq(lst, lst2)
	-- "list simple (or shallow) equal" 
	-- compare list/array portion of tables
	-- (uses '==' for comparison --ie identity-- 
	-- for tables. does not recurse)
	if #lst ~= #lst2 then return false end
	for i = 1, #lst do 
		if lst[i] ~= lst2[i] then return false end 
	end
	return true
end

function list.find(lst, elem)
	-- return index of first occurence of elem or false
	for i,v in ipairs(lst) do 
		if v == elem then return i end 
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

-- list-based set functions

function list.uniq(lst)
	-- return a list of unique elements in lst (named after unix's uniq)
	local t = {}
	local ul = list()
	for i,e in ipairs(lst) do
		if not t[e] then
			table.insert(ul, e)
			t[e] = true
		end
	end
	return ul
end

function list.uinsert(lst, e)
	-- set insert:  append an element only if it is not already in list
	for i,x in ipairs(lst) do if e == x then return end end
	return table.insert(lst, e)
end

function list.uextend(lst, l2)
	-- set extend:  set insert all elements of l2 in lst 
	--   (ie insert only unique elements)
	--   if lst is a list-based set, after uextend,  lst is still a set.
	for i, x in ipairs(l2) do list.uinsert(lst, x) end
	return lst
end

function list.uremove(lst, e)
	-- remove 1st occurence of e in lst (set remove for a list-based set)
	-- return the removed element e, or nil if e was not found
	local ei
	for i,x in ipairs(lst) do
		if e == x then  ei = i;  break  end
	end
	if ei then 
		table.remove(lst, ei)
		return e
	else
		return nil
	end
end

-- a very simple list iterator 
-- use __call() to allow the list to be used as its own iterator.
-- usage: 
--	lst = list{11,22,33}
-- 	for i, e in lst do print(i, e) end

function list.__call(l, unused, i) -- keep 'unused' here. see note.
	i = (i or 0) + 1
	local e = l[i]
	return e and i, e
end

-- Note: why 'unused'?  The __call metamethod of lst is called 
-- with lst as first argument, plus the actual arguments of the call 
-- as second and third arguments. For a list lst, the call "lst(x, y)"
-- is actually "list.__call(lst, x, y)".
-- see a more complete explanation in he.i or junk/misc.lua
--


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
	table.insert(t[k], e)
end

function he.ucollect(t, k, e)
	-- appends e to list-based set t[k] if not already in there.  
	-- creates list if t[k] doesnt exist.
	if not t[k] then t[k] = list() end
	list.uinsert(t[k], e)
end

function he.keys(t, pred, ...) 
	-- returns list of keys of t
	-- if predicate, returns only keys for which pred(v, ...) is true
	local kt = list()
	for k,v in pairs(t) do 
		if not pred or pred(v, ...) then table.insert(kt, k) end 
	end
	return kt  
end

function he.sortedkeys(t, pred, ...)  
	-- returns sorted list of keys of t
	-- if predicate is defined, return only keys for which 
	-- pred(v, ...) is true
	-- sort works with heterogeneous keys (use cmpany) 
	-- in case of performance issue, simply use sorted(keys(. . .)) 
	local kt = he.keys(t, pred, ...); 
	table.sort(kt, he.cmpany); 
	return kt 
end

function he.count(t, pred, ...)  
	-- returns number of keys in table t
	-- if pred, count only keys for which pred(v, ...) is true
	local n = 0
	if pred then 
		for k,v in pairs(t) do 
			if pred(v, ...) then  n = n + 1 end 
		end
	else
		for k,v in pairs(t) do n = n + 1 end
	end--if pred
	return n
end


------------------------------------------------------------------------
-- string functions


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
			if string.find(s, su, j, true) == j then 
				return su 
			end
		end
	end--if
end--endswith

function he.lpad(s, w, ch) 
	-- pad s to the left to width w with char ch (ch is a 1-char 
	-- string, defaults to space)
	ch = ch or " "
	assert(#ch == 1)
	if #s < w then 
		s = ch:rep(w - #s) .. s
	end
	return s
end

function he.rpad(s, w, ch) 
	-- pad s to the right to width w with char ch (ch is a 1-char 
	-- string, defaults to space)
	ch = ch or " "
	assert(#ch == 1)
	if #s < w then 
		s = s .. ch:rep(w - #s)
	end
	return s
end

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
			table.insert(t, sub(s, i0, i-1))
			i0 = j + 1 ;  cnt = cnt - 1
		else break end --if
	end --while
	table.insert(t, sub(s, i0, -1))
	return t
end --split()

function he.spsplit(s)
	-- split string s by any sequence of space characters 
	-- (sp, tab, cr, nl)
	local insert = table.insert
	local t = he.list()
	for x in s:gmatch("(%S+)") do insert(t, x) end
	return t
end --spsplit()


function he.eolsplit(s) 
	-- split s in a list of lines
	return he.split(s, '\r?\n') 
end

function he.lines(s)
	-- lines iterator:
	-- "for l in he.lines(txt) do ... end"
	-- return all the lines without the eol separator
	-- (including the last line even if it doesn't end with eol)
	-- assume lines are separated with CR, LF or CRLF
	-- Note: CR alone _is_ a separator except in sequence CRLF
	-- so "a\rb\n\rc\r\n" => "a", "b", "", "c"
	return  string.gmatch(s, "([^\n\r]*)\r?\n?")
end

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
	return string.gsub(he.rstrip(s), '[ \t]+(\r?\n)', '%1') 
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
	if type(x) == 'number' 
	   or type(x) == 'boolean' 
	   or type(x) == 'nil' then
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

function he.ntos(n, nf, pad)
	-- "number to string"
	-- represent number n as a string with a thousand separator (',')
	-- use optional printf format 'nf' (default is %d)
	-- eg. ntos(12345) -> "12,345",  
	-- with Lua 5.3, if n is not an integer, default format '%.2f' is used
	-- eg. ntos(1234.5) -> "1,234.50"
	-- pad is an optional. If provided, the represented number is 
	-- left-padded with spaces so that the result length is 'pad'
	-- eg. ntos(1234.5, nil, 10) == "  1,234.50"
	
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
	s = table.concat(t, '.')  
	if pad then return he.lpad(s, pad) end
	return s
end--ntos()


------------------------------------------------------------------------
-- date functions

function he.isodate(t, f)
	-- return formatted dat-time as a string
	-- t: a unix time (integer). t is optional. defaults to now.
	-- f: a format indicator (see values in table below)
	-- f is optional. defaults to "1" -- local time, 20090709_122122
	if type(t) == 'string' then f = t; t = nil end
	f = f or "1"
	local ft = {
	  ["0"]  = "%Y%m%dT%H%M%S",            -- 20090709T122122  (local)
	  ["0u"] = "!%Y%m%dT%H%M%SZ",          -- 20090709T122122  (utc)
	  ["1"]  = "%Y%m%d_%H%M%S",            -- 20090709_122122  (local)
	  ["1u"] = "!%Y%m%d_%H%M%S",           -- 20090709_122122  (utc)
	  ["2"]  = "%Y-%m-%d %H:%M:%S",        -- 2009-07-09 12:21:22 (local)
	  ["2u"] = "!%Y-%m-%d %H:%M:%S UTC",   -- 2009-07-09 12:21:22 UTC
	  ["2z"] = "%Y-%m-%d %H:%M:%S %z",     -- 2009-07-09 12:21:22 -0500
	  ["2Z"] = "%Y-%m-%d %H:%M:%S %Z",     -- 2009-07-09 12:21:22 EST
	}
	local fmt = ft[f] or ft["1"]
	return os.date(fmt, t)
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
	-- return content of file 'fname' or nil, msg in case of error
	local f, msg, s
	f, msg = io.open(fname, 'rb')
	if not f then return nil, msg end
	s, msg = f:read("*a")
	f:close()
	if not s then return nil, msg end
	return s
end

function he.fput(fname, content)
	-- write 'content' to file 'fname'
	-- return true in case of success, or nil, msg in case of error
	local f, msg, r
	f, msg = io.open(fname, 'wb')
	if not f then return nil, msg end
	r, msg = f:write(content)
	f:flush(); f:close()
	if not r then return nil, msg else return true end
end

------------------------------------------------------------------------
-- OS / shell functions

local strf = string.format

function he.shell(cmd, opt)
	-- execute the command 'cmd' in a subprocess with popen()
	-- (see the Lua os.popen() description) 
	-- opt is an optional table with additional optional parameters.
	-- return succ, code, strout, strerr  where succ is a boolean
	-- (nil if the command failed or true), code is an integer status 
	-- code. it is either the command exit code if the process exited, 
	-- or a signal code if the process was interrupted by a signal
	-- (the signal code is the signal value + 256).
	-- 'strout' and 'strerr' are the command stdout and stderr 
	-- returned as strings. They are captured in temp files or 
	-- directly by popen() - see the options in the 'opt' table.
	--
	-- opt.cwd = nil | dirpath
	--    if defined, change working dir to dirpath
        --    before running the command
	-- opt.strin
	--    a string that is passed to the command as stdin
	-- opt.stdin = nil | "tmp"
	--    (ignored if opt.strin is not defined)
	--    'tmp' => the value of opt.strin is copied to a temp file
	--        and the command stdin is redirected to the temp file.
	--        The temp file is removed after execution.
	--    nil => the opt.strin value is written to the popen pipe 
	--       as the command stdin (popen mode 'w').
 	-- opt.stdout = nil | "tmp"
	--    'tmp' => the command stdout is captured in a temp file and 
	--       returned. The temp file is removed after execution
	-- opt.stderr = nil | "tmp" | "null | "stdout"
	--    "stdout" or nil => stderr is redirected to stdout
	--       (equivalent to appending " 2>&1 " after the command)
	--    "tmp" => stderr is captured in a temp file and returned. 
	--        The temp file is removed after execution.
	--    "null" => stderr is redirected to /dev/null.
	--
	local strout, strerr = "", ""
	local redir_in, redir_out, redir_err = "", "", ""
	local tmpin, tmpout, tmperr
	
	opt = opt or {}  -- opt is optional
	
	-- the shell command template
	local shfmt = [[
		set -e
		{
		%s
		%s
		} %s %s %s ]]

	-- optional cd before running the command
	local chdir = ""
	if opt.cwd then chdir = "cd " .. opt.cwd end
	
	local mode = 'r' -- the popen() mode
	
	-- setup stdin redirection, if needed
	if opt.strin then
		if not opt.stdin then 
			mode = 'w'
		elseif opt.stdin == 'tmp' then
			tmpin = tmpname()
			he.fput(tmpin, opt.stdin)
			redir_in = strf(" <%s ", tmpin)
		else
			return nil, "invalid opt.stdin"
		end
	end

	-- setup stderr redirection, if needed
	if opt.stderr == "tmp" then
		tmperr = tmpname()
		redir_err = strf(" 2>%s ", tmperr)
	elseif opt.stderr == "null" then 
		redir_err = " 2> /dev/null "
	elseif opt.stderr == "stdout" or not opt.stderr then 
		redir_err = " 2>&1 "
	end
	
	-- setup stdout redirection, if needed
	if opt.stdout == "tmp" then
		tmpout = tmpname()
		redir_out = strf(" >%s ", tmpout)
	end
	
	-- execute command
	local shcmd = strf(shfmt, chdir, cmd, redir_in, redir_out, redir_err)
--~ 	print("MODE: " .. mode)
--~ 	print("SH: " .. shcmd)
	local f = io.popen(shcmd, mode)
	if mode == 'w' then
		f:write(opt.strin)
	else
		strout = f:read("*a")
	end
	local succ, exit, status = f:close()
	
	-- collect stdout, stderr and remove temp files if any
	if tmpin then os.remove(tmpin) end
	if tmpout then
		strout = he.fget(tmpout)
		os.remove(tmpout)
	end
	if tmperr then
		strerr = he.fget(tmperr)
		os.remove(tmperr)
	end
	
	-- return results
	if exit == "signal" then status = status + 256 end
	return succ, status, strout, strerr

end--shell()

function he.sh(cmd)
	-- convenience function. execute a command (with shell())
	-- on success, return the stdout
	-- on failure, return nil, msg
	-- msg is "<status>. <stdout/stderr>"
	local succ, code, strout = he.shell(cmd)
	if succ then return strout end
	return strf("Exit code: %s.  %s", code, strout)
end --sh()


function he.source_line(level)
	-- return <sourcefilename>:<current line>
	-- level is the caller level: 
	--    2: where source_line() is called (this is the default)
	--    3: where the caller of source_line() is called
	--    etc.
	level = level or 2
	local info = debug.getinfo(level) 
	if not info then return "[nil]:-1" end
	return string.format("%s:%s", info.short_src, info.currentline)
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
-- small pathname utility functions
--
he.pathsep = string.sub(package.config, 1, 1)  -- path separator

function he.tmpdir()
	return os.getenv('TMP') or '/tmp'
end

function he.mktmpdir()
	-- make a temp directory with a unique name.
	-- return the temp dir pathname or nil, errmsg
	local tmp = he.tmpdir()
	local cmd = string.format(
			"td=%s/he-%s-$$ ; mkdir $td; echo -n $td", 
			tmp, he.isodate())
	return he.sh(cmd)
end

function he.rmdir(dirpath)
	-- remove directory and all its content (beware!! powerful footgun!)
	return he.sh("rm -r " .. dirpath)
end

local function striprsep(p) 
	-- remove sep at end of path
	if p:match('^%a:/$') or p:match('^/$') then return p end
	return p:gsub('/$', '') 
end

function he.basename(path, suffix)
	-- works like unix basename.  
	-- if path ends with suffix, it is removed
	-- if suffix is a list, then first matching suffix in list 
	-- is removed
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

function he.makepath(dirname, name)
	-- returns a path made with a dirname and a filename
	-- if dirname is "", name is returned
	if dirname == "" then return name end
	if dirname:match('/$') then return dirname .. name end
	return dirname .. '/' .. name
end

function he.isabspath(p)
	-- return true if p is an absolute path ('/something')
	return p:match('^/')
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
		table.insert(rl, 
			(type(v) == "table") and he.t2s(v) or repr(v))
	end
	return '{' .. table.concat(rl, ', ') .. '}'
end

function he.t2s(t, depth)
	-- return table t as a string 
	-- (an evaluable lua table, at least for bool, str and numbers)
	-- (!!cycles are not detected!! - t2s() errors if it recurses
	-- more than 20 levels)
	local repr, app, join = he.repr, he.list.app, he.list.join
	depth = (depth or 0) + 1
	if depth > 20 then
		error("he.t2s: depth error")
	end
	if type(t) ~= "table" then return repr(t) end
	if getmetatable(t) == he.list then return he.l2s(t)  end
	local rl = {}
	-- pairs() is no longer deterministic: several runs on same table
	-- return elements in different order...  (lua 5.3?)
	for i, k in ipairs(he.sortedkeys(t)) do 
		if k == "__index" then 
			-- skip it (or infinite recursion on classes...)
		else 
			table.insert(rl, '[' .. repr(k) .. ']=' 
				.. he.t2s(t[k], depth)) 
		end
	end
	return '{' .. table.concat(rl, ', ') .. '}'
end--t2s()

-- display any object

function he.pp(...)
	local repr = he.repr
	local x
	for i = 1, select('#', ...) do
		x = select(i, ...)
		if type(x) == 'table' then 
			he.printf("pp: %s   metatable: %s",  
				tostring(x), tostring(getmetatable(x)))						
			local kl = he.sortedkeys(x)
			for i,k in ipairs(kl) do
				he.printf("	| %s:  %s", 
					repr(k), repr(x[k]))
			end
		else he.printf("pp: %s", he.repr(x))
		end
	end
end


function he.errf(...) error(string.format(...)) end
function he.printf(...) print(string.format(...)) end

function he.px(s) 
	-- hex dump the string s
	-- if s is an integer, dump the memory representation of s (8 bytes)
	local strf = string.format
	if math.type(s) == "integer" then s = ("I8"):pack(s) end
	for i = 1, #s-1 do
		io.write(strf("%02x", s:byte(i)))
		if i%4==0 then io.write(' ') end  -- adjust as needed
		if i%8==0 then io.write(' ') end
		if i%16==0 then io.write('') end
		if i%32==0 then io.write('\n') end
	end
	io.write(strf("%02x\n", s:byte(#s)))
end

function he.pix(i) 
	-- print integer i as a hex number
	pf("0x%08x", i)
end

------------------------------------------------------------------------
-- elapsed time, used memory

-- replace elapsed() and dual time()/clock() display with  a simpler 
-- clock()-based function (looks like clock() is "the best" source for
-- elapsed time (with a precision ~ 0.1s)
-- (seems reasonable at least on linux and windows)

function he.clock_start()
	he.clock_start_value = os.clock()
end

function he.clock()
	return os.clock() - (he.clock_start_value or 0)
end

function he.clock_print(msg)
	msg = msg or "elapsed"
	print(string.format("%s: %.1f", msg, he.clock()))
end


function he.mem() 
	-- return used memory, in bytes
	collectgarbage()
	return math.floor(collectgarbage'count' * 1024) 
end

function he.mem_print(m, msg)
	-- print used memory in a human readable format ("1,000,000")
	msg = msg or "Used memory (in bytes): "
	m = m or he.mem()
	print(msg .. he.ntos(m, "%d", 15))
end


------------------------------------------------------------------------
-- extend environment

function he.extend_string()
	-- extend string module with the he module string functions
	string.startswith  =  he.startswith
	string.endswith  =  he.endswith
	string.lpad  =  he.lpad
	string.rpad  =  he.rpad
	string.split  =  he.split
	string.spsplit  =  he.spsplit
	string.eolsplit  =  he.eolsplit
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


------------------------------------------------------------------------
return he 

