
# =======
# Imports
# =======

import os

# =========
# Constants
# =========

const
  NimblePkgName*    {.strdefine.} = ""
  NimblePkgVersion* {.strdefine.} = ""

  DefaultConfigPath* = getConfigDir() / NimblePkgName / "config.toml"
  DefaultUsersDbPath* = getConfigDir() / NimblePkgName / "users.db"

  DefaultServerPort* = 5000

  DefaultDetailedVersion* = false

  DefaultVerbosityLevel* = "none"

  FieldDelimiters* = {':'}

  DefaultAdminUsername* = "admin"
  DefaultAdminPassword* = "1234abcd"

  # =====
  # Flags
  # =====

  Flag_Long_Help* = "help"
  Flag_Short_Help* = "h"

  Flag_Long_Config* = "config"
  Flag_Short_Config* = "c"

  Flag_Long_DetailedVersion* = "detailed"
  Flag_Short_DetailedVersion* = "d"

  Flag_Long_ServerPort* = "port"
  Flag_Short_ServerPort* = "p"

  Flag_Long_ListTags* ="list-tags"

  Flag_Long_Verbosity* = "verbosity"
  Flag_Short_Verbosity* = "v"
