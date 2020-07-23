# =======
# Imports
# =======

# Standard Library Imports
import logging
import strutils
import parseutils

# Third Party Package Imports
import commandeer

# Package Imports
import kisurupkg/[ config, defaults, models ]
import kisurupkg/command/[ add, remove, search, server, usage, version ]

# ===========
# Entry Point
# ===========

proc main() =

  commandline:
    option setConfigurationPath, string, Flag_Long_Config, Flag_Short_Config, DefaultConfigPath
    option setVerbosity, string, Flag_Long_Verbosity, Flag_Short_Verbosity, DefaultVerbosityLevel
    subcommand Command_Add, ["add", "insert"]:
      arguments Add_Arguments, string
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("add").join("\n")
    subcommand Command_Remove, ["remove", "rm"]:
      arguments Remove_Arguments, string
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("remove").join("\n")
    subcommand Command_Search, ["search", "query"]:
      option setListTags, bool, Flag_Long_ListTags, ""
      arguments Search_Arguments, string, atLeast1 = false
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("search").join("\n")
    subcommand Command_Server, ["server"]:
      option setServerPort, int, Flag_Long_ServerPort, Flag_Short_ServerPort, DefaultServerPort
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("server").join("\n")
    subcommand Command_Usage, ["help", "usage"]:
      arguments Usage_Arguments, string, atLeast1 = false
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("help").join("\n")
    subcommand Command_Version, ["version"]:
      option setDetailedVersion, bool, Flag_Long_DetailedVersion, Flag_Short_DetailedVersion, DefaultDetailedVersion
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("version").join("\n")
    #subcommand Command_Edit, ["edit", "modify"]:
    #  option set
    #  exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("edit").join("\n")
    exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage().join("\n")

  let config = loadConfiguration(setConfigurationPath)
  let level = parseEnum[VerbosityLevel](setVerbosity, config.verbosity)
  let logger = newConsoleLogger(levelThreshold = @(level))
  logger.addHandler()

  if Command_Usage:
    info("Recognized Command: help/usage")
    let result = parseUsageCommand(Usage_Arguments)

  if Command_Version:
    info("Recognized Command: version")
    let result = parseVersionCommand(setDetailedVersion)

  if Command_Add:
    info("Recognized Command: add/insert")
    let result = parseAddCommand(config, Add_Arguments)

  if Command_Remove:
    info("Recognized Command: remove/rm")
    let result = parseRemoveCommand(config, Remove_Arguments)

  if Command_Search:
    info("Recognized Command: search/query")
    let result = parseSearchCommand(config, setListTags, Search_Arguments)

  if Command_Server:
    info("Recognized Command: server")
    let result = parseServerCommand(config, setServerPort)

when isMainModule:
  main()
