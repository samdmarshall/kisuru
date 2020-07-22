
# =======
# Imports
# =======

# Standard Library Imports
import strutils
import strformat
import parseutils

#import kisurupkg/[ defaults, models ]
import "models.nim"
import "defaults.nim"

# =========
# Functions
# =========

#
#
proc parseField*(query: string): tuple[key: Fields, value: string] =
  if contains(query, FieldDelimiters):
    var field_name: string
    let index = parseUntil(query, field_name, FieldDelimiters) + 1
    let field = parseEnum[Fields](field_name)
    let value = query[index..query.high]
    result = (field, value)
  else:
    result = (Fields.Name, query)
