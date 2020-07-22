
# =======
# Imports
# =======

import os

# =========
# Constants
# =========

const
  NimblePkgName*    {.strdefine.} = ""
  NimblePkgVersion* {.strdefine.} = ""

  DefaultConfigPath* = getConfigDir() / NimblePkgName / "config.toml"

  DefaultServerPort* = 5000

  DefaultDetailedVersion* = false

  FieldDelimiters* = {':'}
