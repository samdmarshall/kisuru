
# =======
# Imports
# =======

# Standard Library Imports
import options
import nativesockets

# Third Party Package Imports

# Package Imports


# =======
# Exports
# =======

export Port
export nativesockets.`==`

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

    # Section: rss
    scanDirForRssFeed*: string
    baseUrl*: string

  # PageKind* = enum
  #   pkUnknown,
  #   pkSource,
  #   pkStatic

  # PagePath* = tuple[content, metadata: string]

  # Page* = ref PageObj
  # PageObj = object
  #   requestPath*: string
  #   lastModTime*: Time
  #   kind*: PageKind
  #   # of pkSource:
  #   sourcePath*: PagePath
  #   cachePath*: string
  #   # of pkStatic:
  #   staticPath*: string
  #   # of pkUnknown:
  #     # discard

  FilePath* = object
    origin*: Option[string]
    directory*: string
    filename*: string
    extensions*: seq[string]


  PageMetadata* = object
    # rss fields
    title*: string
    summary*: Option[string]
    date*: Option[string]
    # private fields, use methods for these
    published*: bool
    root*: Option[bool]
    disableheader*: Option[bool]
    disablefooter*: Option[bool]


  WebpageKind* = enum
    wpInvalid,
    wpDynamic,
    wpStatic,

  Webpage* = object
    path*: FilePath # this is the path off the host
    case kind*: WebpageKind
    of wpDynamic:
      sourcePath*: FilePath
      cachePath*: FilePath
    of wpStatic:
      staticPath*: FilePath
    else:
      discard
