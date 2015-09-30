-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--
-- a bunch of old / unused / unrelated functions 
-- kept here just in case :-)
--
------------------------------------------------------------------------
 local he = require 'he'

 
------------------------------------------------------------------------
-- string parsing functions
------------------------------------------------------------------------

function he.parse_string(line, pattern, names)
--- parsestring:  parse a string
-- return a tuple with all pattern captures
-- if pattern is nil,  the string is split on spaces, either in as many 
--	  pieces as elements in names, or split on all spaces
-- if names is nil, the tuple is a list {val1, val2, ...}
-- if not, names is a list of tuple element names 
-- tuple is returned as a table with names elements: {name1=val1, ...}
--
	local t
	if pattern then 
		t = { string.match(line, pattern) }
	elseif names then --names but no pattern: split in one piece per name
		t = he.split(line, nil, #names - 1)
	else -- no names, no pattern: just split on white spaces
		t = he.split(line)
	end
	if not t[1] then return nil end -- line doesnt match!
	if names then
		local r = {}
		for i,name in ipairs(names) do r[name] = t[i] end
		return r
	else -- no names
		return t
	end
end

function he.parse_lines(linelist, pattern, options)
--- parselines: parse a list of lines
-- returns a list of tuples
-- options is a table with optional elements:
--	names:  a list of field names (see parse_string())
--	mustmatch:  a boolean.  
--		if true, stop parsing on match error, return nil, line index
--		if false, just ignore non matching lines
-- striplines: a boolean
--	   if true, strip each line before parsing
--
	local rl = list()
	options = options or {}
	local mustmatch = options.mustmatch
	for i, line in ipairs(linelist) do
		if options.striplines then line = line:strip() end
		local r = he.parse_string(line, pattern, options.names)
		if not r and mustmatch then return nil, i  end
		rl:app(r)
	end
	return rl
end


function he.nanopat(s)
--- nanopat - makes lua pattern for very simple common cases
-- returns a lua re pattern
-- nano-syntax:
--		* match anything, non greedy:  '.-'
--		+ idem, but match is captured:  '(.-)'
--		? match one character: '.'
--		space: match one or several space char: '%s+'
--		anything else matches itself
--		 pattern is anchored at beg and end of string: '^...$'
--		eg.  nanopat('abc + *') == '^abc%s+(.-)%s+.-$'
--
	local gsub = string.gsub
	local pat = gsub(s, "(%p)", "%%%1")
	pat = gsub(pat, ' ', '%%s*')
	pat = gsub(pat, '%%%*', '.-')
	pat = gsub(pat, '%%%+', '(.-)')
	pat = gsub(pat, '%%%?', '.')
	pat = '^' .. pat .. '$'
--~	 print(pat)
	return pat
end

------------------------------------------------------------------------
-- predicates, compare functions  (useful for filter, map functions)
------------------------------------------------------------------------

function he.istrue(v1) return v1 end
function he.iseq(v1, v2) return v1==v2 end
function he.isneq(v1, v2) return v1~=v2 end
function he.islt(v1, v2) return type(v1)==type(v2) and v1<v2 end
function he.isle(v1, v2) return type(v1)==type(v2) and v1<=v2 end
function he.isgt(v1, v2) return type(v1)==type(v2) and v1>v2 end
function he.isge(v1, v2) return type(v1)==type(v2) and v1>=v2 end

function he.isbw(v1, lo, hi) 
	return  (not lo or (type(v1)==type(lo) and v1>=lo)) 
		and (not hi or (type(v1)==type(hi) and v1 < hi)) 
end

function he.isinlist(v1, v2) return type(v2) == "table" and list.has(v2, v1) end
function he.isinstring(v1, v2) return type(v2)=="string" and string.find(v2, v1) end 
function he.iskeyof(v1, v2) return type(v2)=="table" and v2[v1] end

function he.isin(v1, v2) -- combine isinlist() and isinstring()
	if type(v2) == "table" then return list.has(v2, v1) end
	if type(v2) == "string" then return string.find(v2, v1) end
	return nil
end

function he.notp(v1, pred, ...) 
	-- notp:  test if a predicate is not true
	return not pred(v1, ...)  
end

function he.testf(t, f, pred, ...)
-- testf: tuple field predicate - assume t is a tuple (list or dict)
-- f is a tuple field index or name
-- (this can be used in map, filter,... for lists of tuples - eg.:
--   adults = lst:filter(he.testf, 'age', he.isge, 18)
-- if no argument after 'f' is passed, returns true if field f is defined
	if pred then return pred(t[f], ...)  end
	return t[f] ~= nil  -- (if t[f] == false, it is considered as defined)
end

function he.testv(k, v, pred, ...) 
-- testv:  applies a predicate to the value in a key-value pair k,v. 
-- returns k,v if pred(v, ...) is true.  Else, return nil 
-- can be used with tmap() to implement a filter on a table
	if pred(v, ...) then return k, v end 
end

function he.testk(k, v, pred, ...) 
--testk: same as testv but the predicate is applied to the key.	 
	if pred(k, ...) then return k, v end 
end

function he.reccmp(fn1, fn2, fn3)
	-- returns a function which compares two records (tables) 
	-- on one up to three fields. 
	-- fn1, fn2, fn3 are field indices or names, fn2 and fn3 are optional
	-- fields are assumed to exist and have same type in both tables and
	-- be comparable with '<' (homogeneous numbers or strings)
	-- Can be used to sort lists of records. 
	-- eg. to sort a list of lists on elements 3 then 5:
	--	table.sort(lst, he.reccmp(3, 5))
	-- if no argument is provided, tables are compared on first field
	fn1 = fn1 or 1
	return function(t1, t2)
		if t1[fn1] < t2[fn1] then return true
		elseif t1[fn1] > t2[fn1] then return false
		elseif fn2 and t1[fn2] < t2[fn2] then return true
		elseif fn2 and t1[fn2] > t2[fn2] then return false
		elseif fn3 and t1[fn3] < t2[fn3] then return true
		else return false
		end
	end--function
end -- reccmp

function he.reccmpany(fn1, fn2, fn3)
	-- same as he.reccmp() but uses compare_any(), so
	--	field values may be heterogeneous
	local cmp = he.compare_any
	fn1 = fn1 or 1
	return function(t1, t2)
		if cmp(t1[fn1], t2[fn1]) then return true
		elseif not (t1[fn1] == t2[fn1]) then return false
		elseif fn2 and cmp(t1[fn2], t2[fn2]) then return true
		elseif fn2 and not (t1[fn2] == t2[fn2]) then return false
		elseif fn3 and cmp(t1[fn3], t2[fn3]) then return true
		else return false
		end
	end--function
end -- reccmpany


------------------------------------------------------------------------
-- list, table manipulation
------------------------------------------------------------------------

function list.makeindex(lst, fn)
	-- return a table built from list lst
	-- if fn is a function, each element e in list is inserted in new table
	-- with key fn(e)  --  makeindex({a,b,c}, f) => {f(a)=a, f(b)=b, f(c)=c}
	-- if fn is a string or number, it is assumed that each element e 
	-- is a table, and e is inserted in new table with key e[fn]
	--	makeindex({a,b,c}, fn) => {a[fn]=a, b[fn]=b, c[fn]=c}
	-- else fn is ignored, function returns a set:
	--	makeindex{a,b,c} => {a=1, b=1, c=1}
	local t = {}
	if type(fn) == "function" then
		for i,e in ipairs(lst) do t[fn(e)] = e end
	elseif type(fn) == "string" or type(fn) == "number" then
		for i,e in ipairs(lst) do t[e[fn]] = e end
	else -- build a set
		for i,e in ipairs(lst) do t[e] = 1 end
	end--if
end

function he.tmap(t, f, ...)
	-- maps function f over table t
	-- f(k, v, ...) is applied to each element k, v of table t
	-- creates a new table with results of f
	--		- f should returns ka, va  
	--		-  ka,va is inserted in new table only if ka is non false)
	local r = {}
	local ka, va
	for k, v in pairs(t) do
		ka, va = f(k, v, ...)
		if ka then r[ka] = va end
	end
	return r
end

function he.tmapl(t, f, ...)
	-- maps function f over table t
	-- f(k, v, ...) is applied to each element k, v of table t
	-- creates a new _list_ with result of f(k, v)
	--		- f should returns a value va  
	--		-  va is inserted in new list only if va is non false)
	--		- (=> cannot be used to create a list with false elems)
	-- if f is nil, f is assumed to be (k,v) => v 
	--	 ie mapl(t) creates a (shallow) copy of values of t
	local r = list()
	local va
	for k, v in pairs(t) do
		if f then va = f(k, v, ...) else va = v end
		if va then app(r, va) end
	end
	return r
end


------------------------------------------------------------------------
-- serialize, deserialize
------------------------------------------------------------------------



function he.serialize(x)
-- produce a lua source representation of x
-- assume x contains only booleans, numbers, strings and tables 
--	tables can be he.list or raw tables 
--	(metatables are ignored except for he.list)
--	assume there is no cycle/recursive data definition
	local strf = string.format
	if type(x) == 'number' or type(x) == 'boolean' then
		return tostring(x)
	elseif type(x) == 'string' then
		return string.format("%q", x) 
	elseif type(x) == 'table' then
		local mt = getmetatable(x)
		local prefix
		local rl = list()
		if mt == he.list then  -- serialize as a list (only array part)
			prefix = 'list{\n' 
			for i,v in ipairs(x) do 
				app(rl, he.serialize(v)); app(rl, ',\n')
			end
			return prefix .. rl:join().. '}'
		end
		-- serialize as a regular table (all keys)
		prefix = '{\n' 
		for k,v in pairs(x) do 
			app(rl, strf('[%s]=%s,\n', he.serialize(k), he.serialize(v)))
		end 
		return prefix .. rl:join().. '}'
	else
		error('he.serialize: unsupported type ' .. type(x))
	end--if type
end--serialize()

function he.deserialize(s)
	-- return the value of some lua expression serialized by he.serialize()
	-- BEWARE!! 's' is evaluated 
	-- =>	major security risk if s is not safe!!
	-- 		(ie. not produced by serialize())
	local chunk = assert(loadstring('return ' .. s), 
		"he.deserialize: string parse error")
	local x
	if _VERSION == "Lua 5.1" then 
		local e = {list=he.list}
		local f = setfenv(chunk, e)
		x = f()
	else 
		error"he.deserialize(): not yet supported"
	end
	--- local x  =  chunk()
	return x
end--deserialize()



------------------------------------------------------------------------

