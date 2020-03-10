# Package

version       = "0.1.0"
author        = "Samantha Demi"
description   = "a net for catching the ephemeral ghosts"
license       = "BSD-3-Clause"
srcDir        = "src/"
bin           = @["kisuru"]
binDir        = "build/"

backend       = "c"

# Dependencies

requires "nim >= 1.0.6"

requires "jester"
