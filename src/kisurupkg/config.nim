
# =======
# Imports
# =======

import os
import sequtils
import strformat

import parsetoml

# =========
# Constants
# =========

const DefaultConfigPath* = getConfigDir() / "tome" / "config.toml"

# =====
# Types
# =====

type
  Configuration* = object
    path*: string
    # General
    db_path: string # relative to `path.parentDir`
    db_version: int




# =========
# Functions
# =========

#
#
proc loadConfiguration*(path: string): Configuration =
  if not existsFile(path):
    return
  result.path = path

  let data = parseFile(result.path)
  
  if data.hasKey("General"):
    for key, value in data["General"].tableVal.pairs():
      if key == "database":
        result.db_path = value.stringVal
      if key == "version":
        result.db_version = int(value.intVal)

#
#
proc dbPath*(config: Configuration): string =
  let config_path_dir = parentDir(config.path)
  result = config_path_dir / config.db_path

#
#
proc dbTable*(config: Configuration): string =
  result = fmt"v{config.db_version}"