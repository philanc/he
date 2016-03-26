
-- ansiseq - common ANSI terminal sequences

local colors = {
	-- attributes
	reset = "\027[0m",
	clear = "\027[0m",
	bright = "\027[1m",
	dim = "\027[2m",
	underscore = "\027[4m",
	blink = "\027[5m",
	reverse = "\027[7m",
	hidden = "\027[8m",

	-- foreground
	black = "\027[30m",
	red = "\027[31m",
	green = "\027[32m",
	yellow = "\027[33m",
	blue = "\027[34m",
	magenta = "\027[35m",
	cyan = "\027[36m",
	white = "\027[37m",

	-- background
	onblack = "\027[40m",
	onred = "\027[41m",
	ongreen = "\027[42m",
	onyellow = "\027[43m",
	onblue = "\027[44m",
	onmagenta = "\027[45m",
	oncyan = "\027[46m",
	onwhite = "\027[47m",
}

return { -- ansi sequences module 
	colors = colors,
	}

	