-- Copyright (c) 2017  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------------------
--[[ 

stx - minimal itext / items handling



	
]]
------------------------------------------------------------------------
local he = require 'he'
local list = he.list

------------------------------------------------------------------------
-- items

local function parseitem(its)
	-- return it = {"item title", "item body"}
	-- title and body are separated with one or several empty lines
	its = he.strip(its)
	local it = he.split(its, "\n\n+", 1)
	it[2] = it[2] or ""
	return it
end

local function titleline(it)
	-- return first line of title (used for TOC)
	return it[1]:match("^(.-)\n") or it[1]
end

local function itemtos(it)
	-- return the text for an item
	local its = "=== " .. it[1]
	if #it[2] > 0 then its = its .. "\n\n" .. it[2] end
	return its
end

local function maketoc(itemlist)
	-- add a simple table of content (TOC)
	local toc = {"TOC"}
	toc[2] = itemlist:map(titleline):concat("\n")
	return itemtos(toc)
end

local function parseitext(itxt)
	-- parse a text, return header, list of items
	--   header is the text before the first item
	--   each item is a table (see parseitem)
	--   TOC is removed (any item with titleline = "=== TOC")
	itxt = he.stripeol(itxt:gsub("\r", "")) -- clean itxt 
	itxt ="\n" .. itxt .. '\n' -- simplify detection of '===' at end/beg...
	local itsl = he.split(itxt, "\n===%s")
	if #itsl == 0 then return end
	local header = he.strip(itsl[1])
	local itemlist = he.list()
	for i = 2, #itsl do
		local it = parseitem(itsl[i])
		if it[1] == "TOC" or (it[1] == "" and it[2] == "") then
			--continue
		else
			itemlist:insert(it) 
		end
	end--for
	return header, itemlist
end

local function makeitext(itemlist, header, withtoc)
	-- build a text from a list of items, return the text
	-- header (optional): text inserted before the first item
	-- withtoc (optional): a boolean. if true, a TOC is inserted 
	--    between header and first item
	local sep = "\n\n\n"
	local txtl = itemlist:map(itemtos)
	if withtoc then table.insert(txtl, 1, maketoc(itemlist)) end
	if header and header ~= "" then table.insert(txtl, 1, header) end
	txtl:insert("") -- ensure we also have 'sep' at end of text
	return txtl:concat(sep)
end --makeitext()


local function normitext(itxt)
	-- reformat a text containing items (item stripping, std spacing, sep)
	local header, itemlist = parseitext(itxt)
	itxt = makeitext(itemlist, header, true)
	return itxt
end

------------------------------------------------------------------------
local stx = {
	parseitext = parseitext,
	makeitext = makeitext,
	normitext = normitext,
}

------------------------------------------------------------------------
return stx
