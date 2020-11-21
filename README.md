![CI](https://github.com/philanc/he/workflows/CI/badge.svg)

# he

A small bunch of Lua utility functions

* string extensions (split, strip, ...)
* table and list (map, filter, extend, ...)
* OS and file (ISO date and time, read and write file, shell, ...)
* parsing and encoding (CSV, ...)
* unfinished junk

This stuff is definitely NOT stable, and  NOT maintained.  

The core 'he' module is now he/init.lua. It can still be loaded by `require "he"` provided that LUA_PATH includes a `/.../?/init.lua` component. 

The tests assume that 'he'  can be loaded by `require "he"`.

he/zen.lua and he/nacl.lua require respectively the  [luazen](https://github.com/philanc/luazen) and [luatweetnacl](https://github.com/philanc/luatweetnacl) extensions.

License: MIT -- see the file LICENSE

Copyright (c) 2009-2019  Phil Leblanc 
