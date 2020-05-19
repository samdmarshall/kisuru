
# =======
# Imports
# =======


#import tomepkg/config
import "../config.nim"

# =========
# Functions
# =========

proc parseAddCommand*(config: Configuration, args: seq[string]): bool =
  discard