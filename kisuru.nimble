import distros

# Package

version       = "0.1.0"
author        = "Samantha Demi"
description   = "a net for catching the ephemeral ghosts"
license       = "BSD-3-Clause"

srcDir        = "src/"
binDir        = "build/"
bin           = @["kisuru"]

# Dependencies

requires "nim >= 1.4.2"

requires "jester >= 0.5.0"
requires "commandeer >= 0.12.3"
requires "parsetoml >= 0.5.0"
requires "yaml#head"
requires "uuids >= 0.1.11"
requires "gnutls 0.1.0"

requires "schedules"
requires "taskqueue"

foreignDep "openssl"
foreignDep "nginx"
foreignDep "gnutls"

# Tasks

task exec, "build and run the executable":
  exec "nimble run -- ./content/pewpewthespells.toml"

task clean, "clean build artifacts":
  rmDir binDir
