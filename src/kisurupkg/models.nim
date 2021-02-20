
# =======
# Imports
# =======

# Standard Library Imports
import json
import times
import options
import nativesockets

# Third Party Package Imports
import nimjson

# Package Imports


# =======
# Exports
# =======

export Port

# =====
# Types
# =====

type
  Configuration* = object
    # Section: jester
    jesterPort*: Port

    # Section: content
    sourcePath*: string
    cachePath*: string
    staticPath*: string

    # Section: template
    headerTemplate*: string
    footerTemplate*: string

  PageKind* = enum
    pkUnknown,
    pkSource,
    pkStatic

  PagePath* = tuple[content, metadata: string]

  Page* = ref PageObj
  PageObj = object
    requestPath*: string
    lastModTime*: Time
    case kind*: PageKind
    of pkSource:
      sourcePath*: PagePath
      cachePath*: string
    of pkStatic:
      staticPath*: string
    of pkUnknown:
      discard

