
# =======
# Imports
# =======

# Standard Library Imports
import os
import sequtils
import strutils
import strformat

# Third Party Package Imports
import parsetoml

# Local Package Imports
#import kisurupkg/[ defaults, models ]
import "defaults.nim"
import "models.nim"


# =====
# Types
# =====

type
  Configuration* = object
    path*: string
    # General
    db_path: string # relative to `path.parentDir`
    db_version: int
    # Server
    users_db_path*: string # relative to `path.parentDir`
    port*: int
    # Server.auth
    admin_username*: string
    admin_password*: string
    # Logging
    verbosity*: VerbosityLevel




# =========
# Functions
# =========

#
#
proc loadConfiguration*(path: string): Configuration {.raises: [OSError, KeyError, ValueError, IOError, Defect, Exception ] .}=
  if not existsFile(path):
    raise newOSError(OSErrorCode(2))
  result.path = path

  let data = parseFile(result.path)

  if data.hasKey("general"):
    let general = data["general"].tableVal
    for key, value in general.pairs():
      if key == "database":
        result.db_path = value.stringVal
      if key == "version":
        result.db_version = int(value.intVal)
  if data.hasKey("server"):
    let server = data["server"].tableVal
    for key, value in server.pairs():
      if key == "users_db":
        result.users_db_path = value.getStr(DefaultUsersDbPath)
      if key == "port":
        result.port = value.getInt(DefaultServerPort)
    if server.hasKey("auth"):
      let server_auth = server["auth"].tableVal
      for key, value in server_auth.pairs():
        if key == "username":
          result.admin_username = value.getStr(DefaultAdminUsername)
        if key == "password":
          result.admin_password = value.getStr(DefaultAdminPassword)
  if data.hasKey("logging"):
    let logging = data["logging"].tableVal
    for key, value in logging.pairs():
      if key == "level":
        result.verbosity = parseEnum[VerbosityLevel](value.stringVal)

#
#
proc dbPath*(config: Configuration): string =
  let config_path_dir = parentDir(config.path)
  result = config_path_dir / config.db_path

#
#
proc dbTable*(config: Configuration): string =
  result = fmt"v{config.db_version}"
