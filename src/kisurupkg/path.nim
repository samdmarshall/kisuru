
# =======
# Imports
# =======

# Standard Library Imports
import os
import strutils

# Third Party Package Imports


# Package Imports
import "defaults.nim"

# =========
# Functions
# =========

proc resolvePath*(path: string): string =
  case path
  of "/":
    result = path & Path_Index_Html
  else:
    discard
