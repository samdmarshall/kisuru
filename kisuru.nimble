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
foreignDep "lcov"

# Tasks

import os
import strutils
import strformat

task exec, "build and run the executable":
  exec "nimble run -- ./content/pewpewthespells.toml"

task clean, "clean build artifacts":
  rmDir binDir
  rmDir "coverage/"
  rmDir "nimcache/"
  rmFile "lcov.info"

task coverage, "run code coverage":
  for file in listFiles("tests/"):
    let (dir, file, ext) = splitFile(file)
    if file.startsWith("t_") and ext == ".nim":
      exec fmt"""nim --hints:off --nimcache:nimcache/{file} --define:CodeCoverageEnabled c --run tests/""" & file & ext
  exec """lcov --gcov-tool ./tools/llvm-gcov --rc lcov_branch_coverage=1 --base-directory . --directory nimcache/ --zerocounter """
  for test in listFiles(binDir):
    if test.startsWith("t_"):
      exec binDir / test
  exec "touch generated_not_to_break_here"
  exec """lcov --gcov-tool ./tools/llvm-gcov --rc lcov_branch_coverage=1 --capture --base-directory . --directory nimcache/ --output-file lcov.info"""
  rmFile "generated_not_to_break_here"
  exec """genhtml --branch-coverage --legend --output-directory coverage/ lcov.info"""
