
# =======
# Imports
# =======

import strformat


# =========
# Constants
# =========

const
  NimblePkgName {.strdefine.} = ""
  NimblePkgVersion {.strdefine.} = ""

# =========
# Functions
# =========

proc cmdVersion*(): string =
  result = fmt"{NimblePkgName} v{NimblePkgVersion}"

