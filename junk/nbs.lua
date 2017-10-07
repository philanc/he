--require "heap"

henb = require "henb"

opt = {
	bindhost = 'localhost',
	port = 3091,
	exit_server = false,
}
print(henb.serve(opt))
print("nbs done.")

