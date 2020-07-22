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

requires "nim >= 1.2.0"

requires "jester >= 0.4.3"
#requires "httpauth"
requires "libsodium"

requires "commandeer"
requires "parsetoml"

# Tasks

task exec, "build and run the executable":
  exec "nimble run -- --config:./assets/config.toml"

task clean, "Remove Build Artifacts":
  withDir projectDir():
    rmFile "users.db"
    rmDir binDir
  rmDir nimcacheDir()


