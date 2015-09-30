-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[

hefs - file system functions (path, file, directory ...) 

this module uses:  he, lfs


]]
------------------------------------------------------------------------
local he = require 'he'
local lfs = require 'lfs'

_G.lfs = nil  --  (lfs.dll (for 5.1) does not respect the 5.2 convention)

local strip, rstrip, split = he.strip, he.rstrip, he.split
local startswith = string.startswith
local list = he.list
local app, join = list.app, list.join

------------------------------------------------------------------------
local hefs = {}  -- the hefs module

------------------------------------------------------------------------
-- pathname functions


function hefs.basename(path, suffix)
	-- works like unix basename.  
	-- if path ends with suffix, it is removed
	-- if suffix is a list, then first matching suffix in list is removed
	local dir, base = path:match("^(.+)/(.*)$")
	if not base then base = path end
	if not suffix then return base end
	suffix = he.endswith(base, suffix)
	if suffix then return string.sub(base, 1, #base - #suffix ) end
	return base
end

function hefs.dirname(path)
	return path:match("^(.+)/.*$") or ""
end

function hefs.makepath(dirname, name, ext)
	-- returns a path made with a dirname, a filename and an optional ext.
	-- path uses unix convention (separator is '/')
	-- ext is assumed to contain the dot, ie. makepath('/abc', 'file', '.txt')
	if ext then name = name .. ext end
	if he.endswith(dirname, '/') then
		return dirname .. name
	else
		return dirname .. '/' .. name
	end--if
end


local win = he.windows
	-- this flag is usd only for path functions. 
	-- it can be changed if needed 
	-- (eg. working on windows paths on a linux platform)

--local sep = win and '\\' or '/'
--local resep = win and '%\\' or '/'  -- can be used in a re

local sep = '/'
local resep = '/'  -- can be used in a re

hefs.sep, hefs.resep = sep, resep

local function striprsep(p) 
	-- remove sep at end of path
	if p:match('^%a:/$') or p:match('^/$') then 
		return p 
	end
	local rersep = '/$'  
	return p:gsub(rersep, '') 
end

local function cleansep(p)
	p = p:gsub( '//', '/') 
	p = striprsep(p)
	return p
end

local function wdrive(p)
	if p:match('^%a:/') then return p:sub(1,2)
	else return nil
	end
end

function hefs.pisabs(p)
	-- return true if p is an absolute path
	-- either '/something' or 'a:/something'
	return p:match('^%a:/') or p:match('^/')
end

function hefs.psplit(p) 
	local pl = split(p, '/')
	if pl[1] == '' then pl[1] = '/' end
	if pl[#pl] == '' then table.remove(pl, #pl) end
	return pl
end

function hefs.psplitdir(p)
	-- return dir, name
	if p == '' then return "", "" end
	local pl = hefs.psplit(p)
	local name = pl[#pl]
	table.remove(pl, #pl)
	return hefs.pjoin(pl), name
end

function hefs.psplitext(p)
	--return basename, ext
	p = striprsep(p)
	local i0 = 1; local i
	while true do
		i = p:find('.', i0+1,  true)
		if not i then
			if i0 == 1 or p:find(resep, i0) then 
				return p, ''  -- no dot or last dot not in last name
			else break
			end 
		end
		i0 = i
	end --while
	-- i0 index of last dot in last name
	return p:sub(1, i0-1), p:sub(i0+1, #p)
end

function hefs.pjoin(a, b)
	-- build a path from name components
	-- 2 forms: pjoin(namelist) or pjoin(a, b)
	if type(a) == 'table' then 
		return cleansep(join(a, '/'))
	elseif b then 
		return cleansep(a .. '/' .. b)
	else
		return a
	end
end


------------------------------------------------------------------------
-- functions using lfs 


-- lfs synonyms
hefs.chdir = lfs.chdir
hefs.rmdir = lfs.rmdir
hefs.mkdir = lfs.mkdir
hefs.touch = lfs.touch
--

function hefs.currentdir() return he.pnorm(lfs.currentdir()) end

function hefs.fmod(fn) return lfs.attributes(fn, 'modification') end
function hefs.fsize(fn) return lfs.attributes(fn, 'size') end
function hefs.fexists(fn) return not (not lfs.attributes(fn, 'size')) end
function hefs.isdir(fn) return lfs.attributes(fn, 'mode') == 'directory' end
function hefs.isfile(fn) return lfs.attributes(fn, 'mode') == 'file' end

function hefs.issymlink(fn)
	if he.windows then return false
	else
		error('how to detect symlinks??')
	end
end

function hefs.fileinfo(fn)
	-- returns a record (a table) with file info 
	-- (fn=filepath, mod=modification date (iso fmt), siz=file size)
	-- or nil if fn doesn't exist or is not a file
	if not (att(fn, 'mode') == 'file')  then  return nil  end
	return {
		fn = fn,
		mod = he.isodate(att(fn, 'modification')),
		size = att(fn, 'size'),
	}
end


function hefs.samefile(fna, fnb)
	return win and (fna == fnb) or (att(fna, 'ino')  == att(fnb, 'ino'))
end

function hefs.dir(p)
	-- p defaults to cur dir (not implemented by lfs.dir)
	return lfs.dir(p or lfs.currentdir())
end


function hefs.glob2re(globpat)
-- return a lua re pattern implementing a file 'glob' pattern
--   simplified glob pattern matching
--   pattern 'x' matches 'x' only, not 'xy' or 'yx'
--   pattern 'x*' matches 'xabc'
--   pattern '*x' matches 'abcx'
--   pattern '*x*'  matches 'abxcde', but not 'ax' or 'xb' --??why??130324 
	local repat = '^' .. he.escape_re(globpat) .. '$'
	repat = string.gsub(repat, '%%%*', '.*')
	return repat
end

function hefs.find(dp, recurse, modefilter, globpat)
	-- finds entries in dp matching optional pattern globpat 
	-- (globpat is a simplified glob pattern. eg *.i or 123*.z -- no '?')
	-- modefilter is a filter function
	--	  eg. isfile or isdir can be used here
	-- recurses in subdirs if recurse is true (non nil)
	-- 
	dp  = dp or '.'
	local repat = globpat and hefs.glob2re(globpat) or ""
	-- (if repat is '', string.match(fn, repat) will be true)
	if not modefilter then 
		modefilter = function()  return true end
	end
	local pl = he.list()
	local pn, mode
	for fn in lfs.dir(dp) do
		pn = (dp == '.') and fn or hefs.pjoin(dp, fn)
		if fn == '.' or fn == '..' then --continue
		else
			mode = lfs.attributes(pn, 'mode')
--~			 print(mode, pn)
			if modefilter(pn) and string.match(fn, repat)  then 
				app(pl, pn)
			end
			if  recurse and mode == 'directory' then
				pl:extend(hefs.find(pn, recurse, modefilter, globpat))
			end
		end
	end --for
	table.sort(pl)
	return pl
end --find
	

function hefs.files(dp, pat)
	-- find files in dp matching optional glob pattern pat. (no recursion.)
	return hefs.find(dp, false, hefs.isfile, pat)
end

function hefs.dirs(dp, pat)
	-- find dirs in dp matching optional glob pattern pat. (no recursion)
	return hefs.find(dp, false, hefs.isdir, pat)
end

function hefs.findfiles(dp, pat)
	-- find files in dp and subdirs,  matching optional glob pattern pat
	return hefs.find(dp, true, hefs.isfile, pat)
end

function hefs.finddirs(dp, pat)
	-- recursively find dirs in dp matching optional glob pattern pat
	return hefs.find(dp, true, hefs.isdir, pat)
end

function hefs.mkdirs(pn)
	-- recursive mkdir. make sure pn and all parent dirs exists.
	-- doesnt fail if pn already exists and is a dir.
	-- (equivalent to mkdir -p)
	-- error() if  cannot create the directories
	if hefs.isdir(pn) then return true end
	if hefs.fexists(pn) then
		he.errf('hefs.mkdirs(): "%s" exists and is not a directory', pn)
	end
	local pnd, pnb = hefs.psplitdir(pn)
	if  #pnd > 0 then 
		hefs.mkdirs(pnd) 
	end
	hefs.mkdir(pn)
end

function hefs.fpput(pathname, content)
	-- same as he.fput(), but ensure that all directories in 'pathname' exist
	local d, b = hefs.psplitdir(pathname)
	hefs.mkdirs(d)
	he.fput(pathname, content)
end


function hefs.rmdirs(pn)
	-- recursive rmdir
	-- current version doesnt process special files, links, ...
	assert(pn, "hefs.rmdirs(): path must be specified.")
	for i, fname in ipairs(hefs.files(pn)) do
		os.remove(fname)
	end
	for i, dname in ipairs(hefs.dirs(pn)) do
		hefs.rmdirs(dname)
	end
	hefs.rmdir(pn)
end

--
local _dirstack = { }
--
function hefs.pushd(dir, dirstack)
-- push/pop dirs  usage:
-- hefs.pushd('/a/b'); ...do smtg.... hefs.popd()
--
	dirstack = dirstack or _dirstack
	list.app(dirstack, hefs.currentdir())
	hefs.chdir(dir)
	return dir
end

function hefs.popd(dirstack)
	dirstack = dirstack or _dirstack
	local prevdir = list.pop(dirstack)
	if prevdir then hefs.chdir(prevdir)  end
	return prevdir
end


------------------------------------------------------------------------
return hefs
