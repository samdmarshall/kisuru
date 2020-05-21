
# =======
# Imports
# =======

import strformat

#import kisurupkg/defaults
import "../defaults.nim"

# =========
# Functions
# =========

proc cmdVersion*(): string =
  result = fmt"{NimblePkgName} v{NimblePkgVersion}"

proc parseVersionCommand*(): bool =
  echo cmdVersion()