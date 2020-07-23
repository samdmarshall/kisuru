
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

proc cmdUsage*(section: string = ""): seq[string] =
  case section
  of "add":
    result.add fmt"{NimblePkgName} add    [-h|--help] <name> <url address> <tags>"
    result.add fmt"{NimblePkgName} insert [-h|--help] <name> <url address> <tags>"
  of "remove":
    result.add fmt"{NimblePkgName} remove [-h|--help] <query>"
    result.add fmt"{NimblePkgName} rm     [-h|--help] <query>"
  of "search":
    result.add fmt"{NimblePkgName} search [-h|--help] [--list-tags] <query>"
    result.add fmt"{NimblePkgName} query  [-h|--help] [--list-tags] <query>"
  of "help":
    result.add fmt"{NimblePkgName} help  [-h|--help] [add|remove|search|server|version|help]"
    result.add fmt"{NimblePkgName} usage [-h|--help] [add|remove|search|server|version|help]"
  of "version":
    result.add fmt"{NimblePkgName} version [-h|--help] [-d|--detailed]"
  of "server":
    result.add fmt"{NimblePkgName} server [-h|--help]"
  else:
    result.add fmt"{NimblePkgName} [-h|--help] [-c|--config <path>] [add|remove|search|server|version|help]"

proc parseUsageCommand*(args: seq[string]): bool =
  let command =
    if len(args) > 0: args[args.low()]
    else: ""
  for usage in cmdUsage(command):
    echo usage
  result = true
