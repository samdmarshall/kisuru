
# =======
# Imports
# =======

import strformat

# =========
# Constants
# =========

const
  NimblePkgName {.strdefine.} = ""

# =========
# Functions
# =========

proc cmdUsage*(section: string = ""): string =
  case section
  of "add":
    result = fmt"{NimblePkgName} add"
  of "remove":
    result = fmt"{NimblePkgName} [remove|rm]"
  of "search":
    result = fmt"{NimblePkgName} [search|query]"
  of "help":
    result = fmt"{NimblePkgName} [help|usage]"
  of "version":
    result = fmt"{NimblePkgName} version"
  of "server":
    result = fmt"{NimblePkgName} server"
  else:
    result = fmt"{NimblePkgName} [-h|--help] [-c|--config <path>] [add|remove|search|server|version|usage]"

proc parseUsageCommand*(args: seq[string]): bool =
  let command =
    if len(args) > 0: args[args.low()]
    else: ""
  echo cmdUsage(command)
  result = true
