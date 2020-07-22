# =======
# Imports
# =======

# Third Party Package Imports
import commandeer

# Package Imports
import kisurupkg/[ config, defaults ]
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
      option setListTags, bool, "list-tags", ""
      arguments Search_Arguments, string, atLeast1 = false
      exitoption "help", "h", cmdUsage("search")
    subcommand Command_Server, ["server"]:
      option setServerPort, int, "port", "p", DefaultServerPort
      exitoption "help", "h", cmdUsage("server")
    subcommand Command_Usage, ["help", "usage"]:
      arguments Usage_Arguments, string, atLeast1 = false
      exitoption "help", "h", cmdUsage("help")
    subcommand Command_Version, ["version"]:
      option setDetailedVersion, bool, "detailed", "d", DefaultDetailedVersion
      exitoption "help", "h", cmdUsage("version")
    exitoption "help", "h", cmdUsage()

  let config = loadConfiguration(setConfigurationPath)

  if Command_Usage:
    let result = parseUsageCommand(Usage_Arguments)

  if Command_Version:
    let result = parseVersionCommand(setDetailedVersion)

  if Command_Add:
    let result = parseAddCommand(config, Add_Arguments)

  if Command_Remove:
    let result = parseRemoveCommand(config, Remove_Arguments)

  if Command_Search:
    let result = parseSearchCommand(config, setListTags, Search_Arguments)

  if Command_Server:
    let result = parseServerCommand(config, setServerPort)

when isMainModule:
  main()
