-- Copyright (c) 2016  Phil Leblanc  -- see LICENSE file


--[[ 

=== hefs - file system functions (path, file, directory ...) based on lfs

pathname arguments are assumed to use Unix separators ('/')
pathname handling functions defined in module 'he'.

hefs functions:

  currentdir    return current directory (with '/' separators)
  chdir         alias for lfs.chdir
  rmdir         alias for lfs.rmdir
  mkdir         alias for lfs.mkdir
  touch         alias for lfs.touch
  dir           same as lfs.dir, but defaults to the current directory
  
  fmod          return last modification date for a file
  fsize         return size of a file
  fexists       return true if pathname exists
  isdir         directory pathname predicate
  isfile        file pathname predicate
  
  glob2re       turn a simplified "glob" pattern into a Lua re pattern
  glob          return a function matching a simplified "glob" pattern
  
  findmap     	apply a function to all entries in a directory (recursively)
  findfiles		return a list of all file entries in a directory (recursively)
  finddirs      return a list of all directories in a directory (recursively)
  
  mkdirs        create a directory and required parent dirs ('mkdir -p')
  rmdirs        remove a directory and all its content ('rm -r')
  pushd         push a directory (same as command 'pushd')
  popd          pop a directory (same as command 'popd')
  

]]
------------------------------------------------------------------------
local he = require 'he'
local lfs = require 'lfs'

_G.lfs = nil  --  (lfs.dll (for 5.1) does not respect the 5.2 convention)

local strip, rstrip, split = he.strip, he.rstrip, he.split
local list = he.list
local app = list.app

------------------------------------------------------------------------
local hefs = {}  -- the hefs module

he.fs = hefs

------------------------------------------------------------------------
-- pathname functions  (simplified and moved to module he)

------------------------------------------------------------------------
-- functions using lfs 

-- lfs synonyms
hefs.chdir = lfs.chdir
hefs.rmdir = lfs.rmdir
hefs.mkdir = lfs.mkdir
hefs.touch = lfs.touch

local att = lfs.attributes
--

function hefs.currentdir() return he.pnorm(lfs.currentdir()) end

function hefs.fmod(fn) return lfs.attributes(fn, 'modification') end
function hefs.fsize(fn) return lfs.attributes(fn, 'size') end
function hefs.fexists(fn) return not (not lfs.attributes(fn, 'size')) end

function hefs.isdir(fn) 
	return (lfs.attributes(fn, 'mode') == 'directory') and fn 
end
function hefs.isfile(fn) 
	return (lfs.attributes(fn, 'mode') == 'file') and fn 
end

function hefs.issymlink(fn)
	if he.windows then return false
	else
		error('how to detect symlinks??')
	end
end

function hefs.samefile(fna, fnb)
	return win and (fna == fnb) or (att(fna, 'ino') == att(fnb, 'ino'))
end

function hefs.dir(p)
	-- p defaults to cur dir (not implemented by lfs.dir)
	return lfs.dir(p or lfs.currentdir())
end

function hefs.glob2re(globpat)
-- return a lua re pattern implementing a file 'glob' pattern
--   simplified glob pattern matching
--   pattern 'x' matches 'x' only, not 'xy' or 'yx'
--   pattern 'x*' matches 'x', 'xabc'
--   pattern '*x' matches 'x', 'abcx'
--   pattern '*x*'  matches 'abxc', 'ax', 'xb', 'x'
 	local repat = '^' .. he.escape_re(globpat) .. '$'
	repat = string.gsub(repat, '%%%*', '.*')
	return repat
end

function hefs.glob(pat) 
	-- return a function that matches a string against a glob pattern, 
	-- and returns the string in case of success
	-- eg.  glob("x*")("xabc") --> "xabc"
	--      glob("x*")("abcx") --> nil
	local re = hefs.glob2re(pat)
	return function(e) return e:match(re) and e end
end

local function idf(x) return x end -- identity function (default for findmap())

function hefs.findmap(dp, func, norecurse)
	-- iterate on all entries in directory 'dp'. Recurse into subdirectories
	-- except if norecurse is true (default is to recurse).
	-- for each entry 'e', if func(e) is true, its value is appended
	-- to the returned list. if func is nil, the entry 'e' is appended.
	-- dp defaults to the current directory
	func = func or idf -- func defaults to identity
	dp = dp or ""
	local isdir = hefs.isdir
	local pl = he.list()
	-- lfs("") iterates on root directory... (at least on windows)
	local lfsdp = (dp == "") and "." or dp
	for fn in lfs.dir(lfsdp) do
		if fn == '.' or fn == '..' then --continue
		else
			local pn = he.makepath(dp, fn)
			local e = func(pn)
			if e then pl:insert(e) end
			if isdir(pn) and not norecurse then 
				pl:extend(hefs.findmap(pn, func)) 
			end
		end
	end--for
	return pl
end

function hefs.findfiles(dp, func)
	-- same as findmap(), but iterate only on files
	func = func or idf
	local f = function(e) return hefs.isfile(e) and func(e) end
	return hefs.findmap(dp, f)
end

function hefs.finddirs(dp, func)
	-- same as findmap(), but iterate only on directories
	func = func or idf
	local f = function(e) return hefs.isdir(e) and func(e) end
	return hefs.findmap(dp, f)
end

function hefs.files(dp)
	-- return a list of files in directory dp (don't recurse)
	return hefs.findmap(dp, idf, true)
end

function hefs.dirs(dp)
	-- return a list of directories in directory dp (don't recurse)
	return hefs.findmap(dp, idf, true)
end

function hefs.mkdirs(pn)
	-- recursive mkdir. make sure pn and all parent dirs exists.
	-- doesnt fail if pn already exists and is a dir.
	-- (equivalent to unix: mkdir -p)
	-- error() if  cannot create the directories
	if hefs.isdir(pn) then return true end
	if hefs.fexists(pn) then
		he.errf('hefs.mkdirs(): "%s" exists and is not a directory', pn)
	end
	local pnd = he.dirname(pn)
	hefs.mkdirs(pnd) 
	hefs.mkdir(pn)
end

function hefs.rmdirs(pn)
	-- recursive rmdir
	-- current version doesnt process special files, links, ...
	--
	-- this is a dangerous function!!
	-- on a win PC, if admin, could wipe the entire disk
	-- if started in/with wrong arg!!!  or if bug!!!
	-- => consider removing it.
	-- => at least enforce that pn must be an abs path
	--
	assert(pn and he.isabspath(pn), 
		"hefs.rmdirs(): path must be an absolute path.")
	if not hefs.isdir(pn) then
		return nil, "path does not exist or is not a directory"
	end
	for fn in hefs.dir(pn) do
		local fp = he.makepath(pn, fn)
		if fn == '.' or fn == '..' then --ignore them => continue
		elseif hefs.isfile(fp) then 
--~ 			print("os.remove", fp)
			os.remove(fp) 
		elseif hefs.isdir(fp) then 
			hefs.rmdirs(fp)
		end
	end
--~ 	print("hefs.rmdir", pn)
	return hefs.rmdir(pn)
end

--
local _dirstack = list()
--
function hefs.pushd(dir, dirstack)
	-- push/pop dirs  usage:
	-- hefs.pushd('/a/b'); ...do smtg.... hefs.popd()
	-- 
	dirstack = dirstack or _dirstack
	dirstack:insert(hefs.currentdir())
	hefs.chdir(dir)
	return dir
end

function hefs.popd(dirstack)
	dirstack = dirstack or _dirstack
	local prevdir = dirstack:pop()
	if prevdir then hefs.chdir(prevdir)  end
	return prevdir
end

------------------------------------------------------------------------
return hefs

