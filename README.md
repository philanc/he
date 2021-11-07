![CI](https://github.com/philanc/he/workflows/CI/badge.svg)

# he

A small bunch of Lua utility functions

* string extensions (split, strip, ...)
* table and list (map, filter, extend, ...)
* OS and file (ISO date and time, read and write file, shell, ...)

### List of functions

```
  equal         test equality (deep)
  cmpany        compare values with any type 
                (useful to sort heterogeneous lists)

  class         a minimalist class constructor
  list          a simple List class
  
  -- list functions (in the metatable of List instances)
  insert        insert or append an element (same as table.insert)
  remove        remove an element (same as table.remove)
  pop           (same as table.remove)
  concat        join all elements into a string (same as table.concat)
  sort          sort a list (same as table.sort)
  sorted        return a sorted copy of a list
  extend        append all the elements of another list 
  map           map a function over a list
  mapwhile      map a function f over a list until f() returns a false value
  mapfilter     map a function over a list, insert only true results
  reduce	apply a combining function to all elements of a list
  has           test if a list contains some value
  find_elem     find an element that matches a predicate
  check_elems   check that all elements match a predicate
  lseq          test list equality (shallow)
  uniq          return a list with unique elements in a list
  uinsert       same as insert but ensure all elements are unique
  uextend       same as extend but ensure all elements are unique
  uremove       remove first occurence of a value in a list
  
  -- other table functions
  clone         copy a table (shallow copy)
  update        extend a table with the (key, val) from another table
  incr          increment a value in a table (create value if needed)
  collect       append to a list in a table (create list if needed)
  ucollect      same as collect but elements in list are unique
  keys          return table keys
  sortedkeys    return table keys sorted
  count         count elements in a table
  
  -- string functions
  startswith    test if a string starts with  a prefix
  endwith       test if a string ends with  a suffix
  lpad          pad a string on the left
  rpad          pad a string on the right
  split         split a string on a separator pattern
  spsplit       split a string by whitespaces (sp, tab, cr, lf) 
  eolsplit      split a string in lines
  lines         an iterator delivering all the lines in a string
  rstrip        strip whitespace at beginning
  lstrip        strip whitespace at end
  strip         strip whitespace at beginning and end
  stripeol      strip whitespace at each end of line
  stripnl       strip empty lines at beginning and end
  unix2dos      convert LF to CRLF
  dos2unix      convert CRLF to LF
  escape_re     escape a string so it can be used as a re pattern
  repr          return a string representation of a value
  stohex        return a hexadecimal representation of a binary string
  hextos        parse a hex encoded string, return the string
  ntos          convert a number to a string with a thousand separator ','
  spack         serialize lua values as a packed binary string
  sunpack       deserialize a packed binary string to a lua value  
  
  --misc OS functions
  isodate       convert time to an ISO date representation
  isots         convert time to an ISO date compact representation
  iso2time      parse ISO date and return a time (sec since epoch)
  shell         execute a shell command (wraps io.popen())
  
  -- misc file and pathname functions
  fget          return the content of a file as a string
  fput          write a string to a file
  tmpdir        returns a temp directory path
  tmppath       returns a temp path
  basename      strip directory and suffix from a file path
  dirname       strip last component from file path
  fileext       return the extension of a file path
  makepath      concatenate a directory name and a file name
  isabspath     return true if a path is absolute



```




License: MIT -- see the file LICENSE

Copyright (c) 2009-2020  Phil Leblanc 
