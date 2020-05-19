
# =======
# Imports
# =======

#import tomepkg/config
import "../config.nim"

# =========
# Functions
# =========

proc parseRemoveCommand*(config: Configuration, args: seq[string]): bool =
  discard