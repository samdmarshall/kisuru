
# =======
# Imports
# =======

#import tomepkg/config
import "../config.nim"

# =========
# Functions
# =========

proc parseSearchCommand*(config: Configuration, args: seq[string]): bool =
  discard