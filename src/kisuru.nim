# =======
# Imports
# =======


import commandeer

import kisurupkg/config
import kisurupkg/command/[ add, remove, search, server, usage, version ]

# =====
# Types
# =====


# =========
# Constants
# =========


# ===========
# Entry Point
# ===========

proc main() =
  commandline:
    option setConfigurationPath, string, "config", "c", DefaultConfigPath
    subcommand Command_Add, ["add"]:
      arguments Add_Arguments, string
      exitoption "help", "h", cmdUsage("add")
    subcommand Command_Remove, ["remove", "rm"]:
      arguments Remove_Arguments, string
      exitoption "help", "h", cmdUsage("remove")
    subcommand Command_Search, ["search", "query"]:
      arguments Search_Arguments, string
      exitoption "help", "h", cmdUsage("search")
    subcommand Command_Server, ["server"]:
      arguments Server_Arguments, string
    subcommand Command_Usage, ["help", "usage"]:
      arguments Usage_Arguments, string, false
      exitoption "help", "h", cmdUsage("help")
    subcommand Command_Version, ["version"]:
      exitoption "help", "h", cmdUsage("version")
    exitoption "help", "h", cmdUsage()

  let config = loadConfiguration(setConfigurationPath)

  if Command_Usage:
    let result = parseUsageCommand(Usage_Arguments)

  if Command_Version:
    echo cmdVersion()

  if Command_Add:
    let result = parseAddCommand(config, Add_Arguments)

  if Command_Remove:
    let result = parseRemoveCommand(config, Remove_Arguments)

  if Command_Search:
    let result = parseSearchCommand(config, Search_Arguments)

  if Command_Server:
    let result = parseServerCommand(config, Server_Arguments)

when isMainModule:
  main()
