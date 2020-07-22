
# =======
# Imports
# =======

import db_sqlite
import strformat

#import kisurupkg/[config, database, models, parser]
import "../config.nim"
import "../parser.nim"
import "../database.nim"
import "../models.nim"

# =========
# Functions
# =========

proc parseSearchCommand*(config: Configuration, setListTags: bool, args: seq[string]): bool =
  var db = config.initDatabase()

  if setListTags:
    for tag in db.listTags():
      echo tag.name
  else:
    for argument in args:
      let fragment = parseField(argument)
      case fragment.key
      of Fields.Name:
        let entity = db.findBookmarkByName(fragment.value)
        echo fmt"""Name: {entity.name}
URL: {entity.url}
Tags: {entity.tags.join(", ")}"""
      of Fields.Url:
        let entity = db.findBookmarkByUrl(fragment.value)
        echo fmt"""Name: {entity.name}
URL: {entity.url}
Tags: {entity.tags.join(", ")}"""
      of Fields.Tag:
        let entities = db.findBookmarksByTag(fragment.value)
        for entity in entities:
          echo fmt"""Name: {entity.name}
URL: {entity.url}
Tags: {entity.tags.join(", ")}"""
          echo ""

  db.close()
