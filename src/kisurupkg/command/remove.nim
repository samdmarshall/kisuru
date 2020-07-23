
# =======
# Imports
# =======

import logging
import db_sqlite
import strformat

#import kisurupkg/[config, database, models, parser]
import "../config.nim"
import "../database.nim"
import "../models.nim"
import "../parser.nim"

# =========
# Functions
# =========

proc parseRemoveCommand*(config: Configuration, args: seq[string]): bool =
  info("Initializing Database Connection...")
  var db = initDatabase(config)

  for argument in args:
    let fragment = parseField(argument)
    case fragment.key
    of Fields.Name:
      let entity = db.findBookmarkByName(fragment.value)
    of Fields.Url:
      let entity = db.findBookmarkByUrl(fragment.value)
    of Fields.Tag:
      let entity = db.findTag(fragment.value)

  info("Closing Database Connection...")
  db.close()
