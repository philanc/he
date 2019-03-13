

--[[  

=== hegetopt


]]

local he = require "he"


local function parseoptstr(optstr)
	if not optstr:match("^[:%a]*$") then return nil end
	local optdic = {}
	local i = 1
	while i <= #optstr  do
		local c = optstr:sub(i, i)
		local c1 = optstr:sub(i+1, i+1)
		if c ~= ':' then 
			optdic[c] = (c1 == ":") and 'arg' or 'flag'
		end
		i = i + 1
	end
--~ 	ppt(optdic)
	return optdic
end

local function isopt(s)
	return s:match("^%-")
end
	
local function isvalidgroup(s)
	return s:match("^%-%a+$")
end
	
local function optvalue(optdic, opttbl, arglist, i)
	-- return stat, j the next position in arglist
	-- stat:  
	--     1=still more opts, 
	--     2=switch to positional args, 
	--     3=switch to positional args after '--' (args may start with '-')
	--     nil=error
	-- if optflag, value = true
	-- if end of options, return opt=1
	-- if opt error, return opt=nil
	local err = "invalid option: "
	local o, v
	local a = arglist[i]
	if not a then return 2, i end
	if a == '--' then return 3, i+1 end
	if not isopt(a) then return 2, i end -- not an option, -> positional
	if not isvalidgroup(a) then return nil, err .. a end
	a = a:sub(2)
	while true do -- process all options in the group
		o = a:sub(1,1)
		if not optdic[o] then return nil, err .. '-' .. o end
		if optdic[o] == 'flag' then
			opttbl[o] = true
		else -- assume it is an option with argument
			if #a > 1 then -- opt is not the last
				return nil, err .. '-' .. o .. " not last in group"
			end
			i = i + 1
			v = arglist[i]
			if (not v) or isopt(v) then -- argument is ""
				opttbl[o] = ""
				return 1, i
			else
				opttbl[o] = v
				return 1, i + 1
			end
		end
		if #a < 2 then --no more option in the group
			return 1, i + 1  
		else  -- continue parsing the group
			a = a:sub(2) 
		end
	end --while
end	

local function getopt(optstr, arglist)
	-- very simple getopt. 
	-- arglist is optional. default is to use gobal 'arg'
	-- restrictions, rules:
	--   - only short opts (one letter, no digit)
	--   - values must be separated from optnames ('-f abc', no '-fabc')
	--   - optflags can be grouped ('-am' or '-a -m')
	--   - last option of a group may have a value ('-am blah')
	--   - all opts come before positional arguments
	--   - option processing stops at '--'
	-- return a table with positional arguments, and option values
	-- eg. with optstr "a:bhv" and arg line 'pgm -v -a hello file1 file2'
	-- the following table is returned:
	--    {"file1", "file2", v=true, a="hello"}
	-- if optstr is not valid (starts with ':', repeated options, 
	-- non-letter character), nil, error_msg is returned
	local ot = {}
	local msg_invalid = "invalid option string: " .. optstr
	local msg_noarg = "missing option value: " 
	local optdic = parseoptstr(optstr)
	if not optdic then return nil, msg_invalid end
	local i = 1
	local pos = 1
	-- stat:  parsing state
	-- 1 = parsing options, 
	-- 2 = parsing positional arguments (no more options)
	-- 3 = parsing positional arguments after '--' (arg may start with '-')
	-- nil = parsing error
	local stat = 1  
	local a, o, v, j
	while true do
		stat, j = optvalue(optdic, ot, arglist, i)
		if not stat then return nil, j end -- optvalue error
		i = j
		if stat >= 2 then break end -- move to positional parameters
	end--while
	while true do -- collect positional arguments
		a = arglist[i]
		if not a then break end
		if isopt(a) and stat == 2 then 
			return nil, "option after positional argument"
		end
		ot[pos] = a
		pos = pos + 1  -- next positional argument		
		i = i + 1 -- next element in arglist
	end --while
	return ot
end

return { -- module
	getopt = getopt,
}
