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


