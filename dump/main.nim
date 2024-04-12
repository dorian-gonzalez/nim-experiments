import std/sugar

let
  x = 10
  y = 20
dump(x + y) # prints: `x + y = 30`

let foo: seq[(float, byte, cstring)] = @[(1, 2, "abc")]

dump foo


dump 1 + 4