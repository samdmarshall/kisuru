
# =======
# Imports
# =======

import uri
import sequtils
import strutils
import parseutils


# =====
# Types
# =====

type
  Tag* = object
    id*: int64
    name*: string

  Bookmark* = object
    id*: int64
    name*: string
    url*: Uri
    tags*: seq[Tag]

  Fields* {.pure.} = enum
    Name,
    Tag,
    Url

# =========
# Functions
# =========

proc newTag*(id: string, name: string): Tag =
  var identifier: int
  discard parseInt(id, identifier)
  result.id = identifier
  result.name = name

proc join*(items: seq[Tag], sep: string): string =
  result = items.mapIt(it.name).join(sep)

proc newBookmark*(id: string, name: string, url: string): Bookmark =
  var identifier: int
  discard parseInt(id, identifier)
  result.id = identifier
  result.name = name
  result.url = parseUri(url)
  result.tags = newSeq[Tag]()
