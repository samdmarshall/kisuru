
# =======
# Imports
# =======

# Standard Library Imports
import times
import strtabs
import strutils
import strformat


# Third Party Package Imports
import uuids

# Package Imports


# =====
# Types
# =====

type
  IcsNodeKind* = enum
    icsInvalid,
    icsComponent,
    icsProperty

  IcsNode* = ref IcsNodeObj
  IcsNodeObj = object
    kind*: IcsNodeKind
    name*: string
    parameters*: StringTableRef
    value*: string
    children*: seq[IcsNode]

# =========
# Constants
# =========

const
  Separator = ":"

  Key_Begin = "BEGIN"
  Key_End = "END"

  Key_Version = "VERSION"
  Key_CalScale = "CALSCALE"
  Key_ProdId = "PRODID"
  Key_UId = "UID"
  Key_Summary = "SUMMARY"
  Key_Sequence = "SEQUENCE"
  Key_DTStart = "DTSTART"
  Key_DTStamp = "DTSTAMP"
  Key_DTEnd = "DTEND"
  Key_Description = "DESCRIPTION"
  Key_Method = "METHOD"

  Name_VCalendar = "VCALENDAR"
  Name_VEvent = "VEVENT"
  Name_VTimeZone = "VTIMEZONE"
  Name_VAlarm = "VALARM"

  Value_Version_Default = "2.0"


# =========
# Functions
# =========

proc `$`*(node: IcsNode): string =
  let lines = newSeq[string]()
  case node.kind
  of icsComponent:
    lines.add fmt"BEGIN:{toUpperAscii(node.name)}"
    for item in node.children:
      lines.add $item
    lines.add fmt"END:{toUpperAscii(node.name)}"
  of icsProperty:
    lines.add fmt"{toUpperAscii(node.name)}{Separator}{node.value}"
  else:
    discard
  result = lines.join("\r\n")

proc `uid`(uuid: UUID = genUUID()): IcsNode =
  return IcsNode(kind: icsProperty, name: Key_UId, value: $uuid)

proc `version`(version: string = Value_Version_Default): IcsNode =
  return IcsNode(kind: icsProperty, name: Key_Version, value: version)


