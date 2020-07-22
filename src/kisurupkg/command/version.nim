
# =======
# Imports
# =======

# Standard Library Imports
import openssl
import sqlite3
import strscans
import strutils
import strformat
import parseutils

# Third Party Package Imports
import libsodium/sodium

# Package Imports
#import kisurupkg/defaults
import "../defaults.nim"

# =========
# Functions
# =========

proc ndigits(input: string; intVal: var int; start: int; n: int): int =
  var x = 0
  var i = 0
  while i < n and i+start < input.len and input[i+start] in {'0'..'9'}:
    x = x * 10 + input[i+start].ord - '0'.ord
    inc i
  if i == n:
    result = n
    intVal = x

proc alphaIndex(index: int): char =
  result = "abcdefghijklmnopqrstuvwxyz"[index]

proc releaseStatus(status: int): string =
  case status
  of 0:
    result = "Development"
  of 1,2,3,4,5,6,7,8,9,10,11,12,13,14:
    result = fmt"Beta {status}"
  else:
    result = "Release"

proc sodium_version_string(): cstring {. importc, dynlib: libsodium_fn .}

proc parseVersionCommand*(setDetailedVersion: bool): bool =
  echo fmt"{NimblePkgName} v{NimblePkgVersion}"

  if setDetailedVersion:
    let openssl_version_str = toHex(int32(getOpenSSLVersion()))
    var major, minor, fix, patch, status: int
    result = scanf(openssl_version_str, "${ndigits(1)}${ndigits(2)}${ndigits(2)}${ndigits(2)}$h$.", major, minor, fix, patch, status)

    echo fmt"""
    Built At: {CompileDate} {CompileTime}
    Nim Lang: v{NimVersion}

    Third Party Libraries:
      sqlite3: v{libversion()}
      openssl: v{major}.{minor}.{fix}{alphaIndex(patch)} {releaseStatus(status)}
      sodium : v{sodium_version_string()}
    """