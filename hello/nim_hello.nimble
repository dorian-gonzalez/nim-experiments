# Package

version       = "0.1.0"
author        = "Dorian González"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"

bin           = @["nim_hello"]

# Dependencies

requires "nim >= 1.6.14"
requires "nimcrypto >= 0.5.4"