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
requires "commandeer"
requires "parsetoml"
requires "yaml#head"
requires "uuids"
requires "gnutls"

requires "schedules"
requires "taskqueue"

foreignDep "openssl"
foreignDep "nginx"
foreignDep "gnutls"

# Tasks

import os
import strutils

task exec, "build and run the executable":
  exec "nimble run -- ./content/pewpewthespells.toml"

task clean, "clean test artifacts":
  for file in listFiles("tests/"):
    let (dir, name, ext) = splitFile(file)
    let is_test_file = name.startsWith("t_")
    let is_source_file = (ext == ".nim")
    let is_executable = extractFilename(file) == toExe(name)
    if is_test_file and not is_source_file and is_executable:
      echo "Removing: " & file
      rmFile file


