
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
    result = fmt"{NimblePkgName} add [-h|--help] <name> <url address>"
  of "remove":
    result = fmt"{NimblePkgName} remove [-h|--help] <name>"
  of "search":
    result = fmt"{NimblePkgName} search [-h|--help] <query string>"
  of "help":
    result = fmt"{NimblePkgName} help [-h|--help] [add|remove|search|server|version|help]"
  of "version":
    result = fmt"{NimblePkgName} version [-h|--help]"
  of "server":
    result = fmt"{NimblePkgName} server [-h|--help]"
  else:
    result = fmt"{NimblePkgName} [-h|--help] [-c|--config <path>] [add|remove|search|server|version|help]"

proc parseUsageCommand*(args: seq[string]): bool =
  let command =
    if len(args) > 0: args[args.low()]
    else: ""
  echo cmdUsage(command)
  result = true
