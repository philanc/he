#!/bin/env lua

-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------------------
--[[

cal.lua 
a variant of the regular 'cal' unix command. 
(smaller, highlight the current date -busybox cal doesn't do it-
and does not require ncurses)
created 160324 

]]

local strf = string.format
local rep = string.rep
local concat = table.concat

local istty = true
local monday1st = true

local function adjust(tt)
	tt = os.date("*t", os.time(tt))
	if monday1st then 
		tt.wday = tt.wday - 1
		if tt.wday == 0 then tt.wday = 7 end
	end
	return tt 
end

local function nextday(tt)
	tt.day = tt.day + 1
	return adjust(tt)
end

local todaytt = adjust(os.date("*t"))

local function istoday(tt)
	return tt.year == todaytt.year 
		and tt.month == todaytt.month
		and tt.day == todaytt.day
end

local function month01(year, month)
	local tt = {year=year, month=month, day=1}
	return adjust(tt)
end
	
local weekdayline = " Mo Tu We Th Fr Sa Su " 
local lineln = #weekdayline
local monthname = {
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	}
local noday = "   " -- 3 spaces

local hilite = "\027[7m" -- reverse
--~ local hilite = "\027[4m" -- underline (cyan on linux console)
--~ local hilite = "\027[1m\027[31m" -- bright red
local normal = "\027[0m"  -- reset/clear
local hiliteln = #hilite + #normal

local function dispday(tt)
	local day = strf("%2d", tt.day)	
	if istoday(tt) and istty then 
		return hilite .. day .. normal, hiliteln
	else
		return day, 0
	end
end
	
local function month_st(year, month)
	--return a list of strings
	local tt = month01(year, month)
	local t = {}
	--	            Mar 2016 
	--	Mo Tu We Th Fr Sa Su 	
	t[1] = strf("%16s %4d ", monthname[month], year)
	t[2] = weekdayline
	for i = 3, 8 do t[i] = " " end
	t[3] = t[3] .. noday:rep(tt.wday-1)
	local i = 3
	local todayline = 0
	while tt.month == month do
		local day, extraln = dispday(tt)
		if extraln > 0 then todayline = i end
		t[i] = t[i] .. day .. " "
		if tt.wday == 7 then
			i = i + 1
		end
		tt = nextday(tt)
	end--while
	for i = 3, 8 do -- make sure all lines have the same length
		local ln = lineln
		if istty and (todayline == i) then 
			-- ignore the extra hilite bytes
			ln = ln + hiliteln 
		end
		-- pad to ensure line length is 'ln'
		t[i] = t[i] .. rep(" ", ln - #t[i])
	end
	return t
end

local function concat_st(t1, t2, t3)
	local t = {}
	local sep = ' '
	for i = 1, 8 do
		t[i] = t1[i] .. sep .. t2[i] .. sep .. t3[i]
	end
	return concat(t, "\n")
end

local function trim_s(year, month)
	-- display 3 months 
	-- (one month before, month, one month after)
	local y1, y3, m1, m3
	y1 = year; m1 = month - 1
	y3 = year; m3 = month + 1
	if month == 1 then
		y1 = year - 1
		m1 = 12
	elseif month == 12 then
		y3 = year + 1
		m3 = 1
	end
	return concat_st(
		month_st(y1, m1), 
		month_st(year, month), 
		month_st(y3, m3)
	)
end

local function year_s(year)
	local yt = {
		trim_s(year, 2),
		trim_s(year, 5),
		trim_s(year, 8),
		trim_s(year, 11),
		}
	return concat(yt, '\n')
end

local function main()
	if arg[1] == "-h" or arg[1] == "--help" then
		print[[

Usage: 
  cal [-p]                 display 3 current months 
  cal [-p] (-y | year)     display current or specified year
  cal (-h | --help)        display this message

Options:
  -p         doesn't highlight the current day
             (no ANSI sequence - useful in a pipe or other non tty usage)
  ]]
		return
	end
	if arg[1] == "-p" then
		istty = false
		table.remove(arg, 1)
	end
	print()
	if #arg == 0 then
		-- display current three months
		print(trim_s(todaytt.year, todaytt.month))
		return
	end
	-- display full year
	local year = tonumber(arg[1]) or todaytt.year
	print(year_s(year))
end

main()
		