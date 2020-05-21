
# =======
# Imports
# =======

# Standard Library Imports
import uri
import xmltree
import strformat
import httpclient
import htmlparser

# Third Party Library Imports

# Package Imports
#import kisurupkg/config
import "../config.nim"

# =========
# Functions
# =========

proc parseAddCommand*(config: Configuration, args: seq[string]): bool =
  let count = len(args)
  var name: string
  var url: Uri
  var tags = newSeq[string]()

  case count
  of 1:
    # argument 1: url
    url = parseUri(args[0])

    let client = newHttpClient()
    let response = client.get($url)
    let html = parseHtml(response.body)
    let title_tags = html.findAll("title")
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

  echo fmt"adding entry: Name: '{name}' Address: '{url}'"
