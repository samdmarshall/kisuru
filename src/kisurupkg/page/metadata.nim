
# =======
# Imports
# =======

# Standard Library Imports
import os
import json
import times
import options
import streams

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
  result.date = some(now().format("MMMM dd, yyyy"))
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
  result = parse(date, "MMMM d, YYYY")

proc toDate*(date: Option[string]): DateTime =
  if date.isSome():
    let date_string = date.get()
    result = date_string.toDate()
