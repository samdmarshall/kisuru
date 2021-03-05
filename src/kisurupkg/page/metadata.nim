
# =======
# Imports
# =======

# Standard Library Imports
import os
import json
import times
import options
import streams
import strutils

# Third Party Package Imports
import yaml

# Package Imports
import "../models.nim"
import "../defaults.nim"
# import kisurupkg/[ models, defaults ]

# ====================
# PageMetadata Methods
# ====================

proc initMetadata*(data: JsonNode): PageMetadata =
  var moment = now()
  result.date = some(moment.format(Default_Metadata_PostDate_Formatter))
  result.time = some(moment.format(Default_Metadata_PostTime_Formatter))
  result.summary = some("website page")
  result.disableheader = some(false)
  result.disablefooter = some(false)
  result.root = none(bool)
  result.published = false
  result = data.to(PageMetadata)

proc initMetadata*(filepath: string): PageMetadata =
  try:
    var metadata_stream = openFileStream(filepath)
    let metadata_json = loadToJson(metadata_stream)
    metadata_stream.close()
    result = initMetadata(metadata_json[0])
  finally:
    discard

proc isPublished*(metadata: PageMetadata): bool =
  return metadata.published

proc isHeaderDisabled*(metadata: PageMetadata): bool =
  result = false
  if metadata.disableheader.isSome():
    result = metadata.disableheader.get()

proc isFooterDisabled*(metadata: PageMetadata): bool =
  result = false
  if metadata.disablefooter.isSome():
    result = metadata.disablefooter.get()

proc isRoot*(metadata: PageMetadata): bool =
  result = false
  if metadata.root.isSome():
    result = metadata.root.get()

proc toDate*(date: string): DateTime =
  result = parse(date, Default_Metadata_PostDate_Formatter)

proc toDate*(date: Option[string]): DateTime =
  if date.isSome():
    let date_string = date.get()
    result = date_string.toDate()

proc toTime*(time: string): Time =
  var date = parse("06:06:06", Default_Metadata_PostTime_Ext_Formatter)
  case count(time, ':')
  of 1:
    date = parse(time, Default_Metadata_PostTime_Formatter)
  of 2:
    date = parse(time, Default_Metadata_PostTime_Ext_Formatter)
  else:
    discard
  result = date.toTime()

proc toTime*(time: Option[string]): Time =
  if time.isSome():
    let time_string = time.get()
    result = time_string.toTime()
