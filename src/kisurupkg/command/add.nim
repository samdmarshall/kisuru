
# =======
# Imports
# =======

# Standard Library Imports
import uri
import logging
import xmltree
import sequtils
import strutils
import db_sqlite
import strformat
import httpclient
import htmlparser

# Third Party Library Imports

# Package Imports
#import kisurupkg/[ config, models ]
import "../config.nim"
import "../models.nim"
import "../database.nim"

# =========
# Functions
# =========

proc parseAddCommand*(config: Configuration, args: seq[string]): bool =
  var name: string
  var url: Uri
  var tags = newSeq[string]()

  let count = len(args)
  info(fmt"Number of arguments: {count}")

  case count
  of 1:
    # argument 1: url
    info("Parsing argument ({args[0]}) as Url")

    url = parseUri(args[0])

    let client = newHttpClient()
    let response = client.get($url)
    let html = parseHtml(response.body)
    let title_tags = html.findAll("title")

    if len(title_tags) == 0:
      name = $url
    else:
      name = title_tags[0].innerText

  of 2:
    # argument 1: name
    info("Parsing argument ({args[0]}) as Name")
    name = args[0]

    # argument 2: url
    info("Parsing argument ({args[1]}) as Url")
    url = parseUri(args[1])
  else:
    # argument 1: name
    info("Parsing argument ({args[0]}) as Name")
    name = args[0]

    # argument 2: url
    info("Parsing argument ({args[1]}) as Url")
    url = parseUri(args[1])

    # argument #: tag
    for argument in args[2..args.high()]:
      info("Parsing argument ({argument}) as Tag")
      let items = argument.split(",")
      tags = tags.concat(items)
    tags.keepItIf( len(it) > 0 )

  debug(fmt"Adding entry: Name: '{name}' Address: '{url}' Tags: {tags}")

  info("Initializing Database Connection...")
  let db = initDatabase(config)
  let id = db.getNextBookmarkId()
  var entry = newBookmark($id, name, $url)
  for tag in tags:
    entry.tags.add newTag("0", tag)

  result = db.insertEntry(entry)

  info("Closing Database Connection...")
  db.close()
