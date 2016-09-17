-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file

--[[ 

heiter - iterators based on coroutines

count        - generates increasing integers
take         - take only the first n elements of an iterable
filter       - filter elements based on a predicate
matching     - filter elements matching a pattern
notmatching  - filter elements not matching a pattern
map          - apply a function to all elements of an iterable
collect      - collect all elements in a table
first        - return the first element of an iterable
flines       - generate lines from a file

except collect and first, all functions return an iterator object
so that they can be chained. Examples:

for i in iter.count(10, 3) -- generate integers starting at 10, step 3
	:take(3) -- keep only the first 3 elements
	do print(i)  -- will print in sequence 10, 13, 16
end

for i in iter.count(10, 3)
	-- keep only odd numbers
	:filter(function(x) return x % 2 == 1 end)
	:take(3) -- keep only the first 3 elements
	do print(i)  -- will print in sequence 13, 19, 25
end

for i in iter.count(10, 3)
	:filter(function(x) return x % 2 == 1 end)
	:map(function(x) return 2 * x end)
	:take(3) 
	do print(i)  -- will print in sequence 26, 38, 50
end

t = iter.count(10, 3)
		:filter(function(x) return x % 2 == 1 end)
		:map(function(x) return 2 * x end)
		:take(3):collect()
now, t contains {26, 38, 50}

t = iter.count(10, 3):first()  -- t == 10

print all the lines of a file in upper case:
for line in iter.flines("hello.txt"):map(string.upper) do
	print(line)
end

]]


local he = require "he"

local yield = coroutine.yield
local resume = coroutine.resume

local function fnil() return nil end

------------------------------------------------------------------------
iter = he.class()

function iter:__call(...)
	return self.f(...)
end

function iter.error(msg)
	return iter{err=true, msg=msg, f=fnil }
end

function iter.cowrap(f)
	if type(f) ~= 'function' then
		error("must be called as iter.cowrap ('.', not ':')")
	end
	return iter{f=coroutine.wrap(f)}
end

-- iterators

function iter.check_err(it)
	-- assert that the iterator is not in error
	-- useful in a chain, eg.:
	--   for x in a():b():c():check_err() do ... end
	--   will error if c is in error
	--   (if all iterators are well formed, 
	--   errors from a and b should be propagated)
	assert(not it.err, it.msg)
	return it
end


function iter.count(n, step)
	-- create a source iterator
	-- generate integers starting at'n', incremented with 'step'
	-- n and step are optional with values 1 and 1
	-- (will run indefinitely)
	n = n or 1
	step = step or 1
	if step==13 then return iter.error"iter.count: step is wrong!!!" end
	return iter.cowrap(function() 
		while true do 
			yield(n); 
			n = n + step 
		end
	end)
end

function iter.items(t)
	-- create a source iterator
	-- return elements of sequence t (same iteration as ipairs)
	return iter.cowrap(function()
		for i, x in ipairs(t) do yield(x) end
		return nil
	end)
end--items

function iter.take(it, count)
	-- create a filter iterator
	-- return the first 'count' elements, eg.:
	--   for n in iter.count():take(10) do ... end
	--   will return integers from 1 to 10
	if it.err then return it end
	return iter.cowrap(function()
		local n = 1
		for x in it do 
--~ 			error'oops'
			if n <= count then yield(x); n = n+1 else return nil end
		end
	end)
end--take

function iter.filter(it, pred)
	-- create a filter iterator
	-- generate only the elements x in it such that pred(x) is true
	if it.err then return it end
	return iter.cowrap(function()
		for x in it do
			if pred(x) then yield(x) end
		end
		return nil
	end)
end--filter

function iter.matching(it, pat)
	-- convenience filter
	-- generates only the elements in 'it' matching pattern 'pat'
	return iter.filter(it, function(x) return string.match(x, pat) end)
end--match

function iter.notmatching(it, pat)
	-- convenience filter
	-- generates only the elements in 'it' not matching pattern 'pat'
	return iter.filter(it, function(x) return not string.match(x, pat) end)
end--nomatch

function iter.map(it, func)
	-- create a map iterator. Apply 'func' to elements of 'it'
	if it.err then return it end
	return iter.cowrap(function()
		for x in it do yield(func(x)) end
	end)
end--map

function iter.dbg(it, msg)
	-- print a debug message
	print("iter.dbg:", it.f, it.err, it.msg, msg)
	return it
end

function iter.collect(it)
	-- put all the iteration results in a list. return the list
	-- or nil, msg if the iterator is in error
	-- (this is a sink, ie. it does not return an iterator)
	local app = table.insert
	if it.err then return nil, it.msg end
	t = {}
	for x in it do app(t, x) end
	return t
end

function iter.first(it)
	-- return the first element of the iteration
	-- or nil, msg if the iterator is in error
	-- (this is a sink, ie. it does not return an iterator)
	if it.err then return nil, it.msg else return it() end
end

function iter.flines(file)
	-- iterate on all lines in file
	-- file can be an open file handle or a filename
	-- if it is a filename, the file will be closed at end of the iteration
	-- if it is a open file handle, it will not be closed
	-- (this is a src)
	local fh, msg
	if type(file) == 'string' then 
		fh, msg = io.open(file)
	elseif io.type(file) == "file" then
		fh = file
	else
		fh = nil
		msg = "iter.flines: 'file' is not a valid open file handle" 
	end
	if not fh then return iter.error(msg) end
	return iter.cowrap(function()
		while true do
			local l = fh:read() -- read line (w/o line terminator)
			if l then 
				yield(l)
			else
				-- close only if invoked with a filename
				if file ~= fh then fh:close() end
				return nil
			end
		end
	end)
end --flines

------------------------------------------------------------------------
return iter



					
