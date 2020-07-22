
# =======
# Imports
# =======

# Standard Library Imports
import uri
import xmltree
import sequtils
import strutils
import strformat
import httpclient
import htmlparser

# Third Party Library Imports

# Package Imports
#import kisurupkg/[ config, models ]
import "../config.nim"
import "../models.nim"

# =========
# Functions
# =========

proc parseAddCommand*(config: Configuration, args: seq[string]): bool =
  var name: string
  var url: Uri
  var tags = newSeq[string]()

  let count = len(args)
  case count
  of 1:
    # argument 1: url
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
    name = args[0]

    # argument 2: url
    url = parseUri(args[1])
  else:
    # argument 1: name
    name = args[0]

    # argument 2: url
    url = parseUri(args[1])

    # argument #: tag
    for argument in args[2..args.high()]:
      let items = argument.split(",")
      tags = tags.concat(items)
    tags.keepItIf( len(it) > 0 )

  echo fmt"adding entry: Name: '{name}' Address: '{url}' Tags: {tags}"
  #let entry = Bookmark(name: name, url: url, tags: tags)
