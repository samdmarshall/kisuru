# =======
# Imports
# =======

# Standard Library Imports
import os
import uri
import json
import times
import options
import streams
import strtabs
# import sequtils
import strutils
import strformat

import packages/docutils/rst
import packages/docutils/rstgen

# Third Party Package Imports
import yaml
import jester

# Package Imports
import "models.nim"
import "defaults.nim"
#import kisurupkg/[ models ]

# =====
# Types
# =====

type
  PageMetadata* = object
    # rss fields
    title*: string
    summary*: Option[string]
    date*: Option[string]
    # private fields, use methods for these
    published: bool
    root: Option[bool]
    disableheader: Option[bool]
    disablefooter: Option[bool]

# ================
# PagePath Methods
# ================

iterator walkPagePattern*(pattern: string): PagePath =
  for path in walkPattern(pattern):
    let content = path
    let valid_content = (content.endsWith(ExtSep & FileExt_Rst))

    let metadata = path & ExtSep & FileExt_Yaml
    let valid_metadata = (metadata.endsWith(ExtSep & FileExt_Rst & ExtSep & FileExt_Yaml))

    let pair_exists = (fileExists(content) and fileExists(metadata))
    if pair_exists and (valid_content and valid_metadata):
      echo fmt"found page: |{content}|{metadata}|"
      yield (content, metadata)

proc getLastModificationTime*(path: PagePath): Time =
  let content_mod_time = getLastModificationTime(path.content)
  let metadata_mod_time = getLastModificationTime(path.metadata)
  if content_mod_time > metadata_mod_time:
    result = content_mod_time
  elif content_mod_time < metadata_mod_time:
    result = metadata_mod_time
  else:
    result = content_mod_time

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

# ============
# Page Methods
# ============

proc isCached*(page: Page, conf: Configuration): bool =
  case page.kind
  of pkSource:
    if len(page.cachePath) > 0:
      result = fileExists(page.cachePath)
    else:
      let path = conf.cachePath / page.requestPath
      result = fileExists(path)
  else:
    result = false

proc isCacheOutdated*(page: Page, conf: Configuration): bool =
  let is_cached = page.isCached(conf)
  if not is_cached:
    result =  true
  else:

    let source_mod_time = getLastModificationTime(page.sourcePath)
    if source_mod_time > page.lastModTime:
      result =  true
    else:
      result =  false

proc expandPageUrl*(page: Page, conf: Configuration): Uri =
  let base = parseUri($conf.baseUrl)
  let path = parseUri(page.requestPath)
  result = base.combine(path)

proc resolvePage*(conf: Configuration, path: string): Page {.gcsafe.} =
  let static_path = conf.staticPath / path
  if fileExists(static_path):
    result = Page(kind: pkStatic, staticPath: static_path)
  else:
    result = Page(kind: pkSource)

    let path_no_ext = changeFileExt(path, "")
    echo fmt"searching for page at path: {path_no_ext}"
    let pattern = conf.sourcePath / path_no_ext & ".*"
    for source in walkPagePattern(pattern):
      let found_path = relativePath(changeFileExt(source.content, ""), conf.sourcePath)
      echo fmt"found: {found_path}"
      if cmpPaths(relativePath(path_no_ext, "/"), found_path) == 0:
        result.sourcePath = source
        result.cachePath = conf.cachePath / path
        break

  case result.kind
  of pkSource:
    if result.isCached(conf):
      result.lastModTime = getLastModificationTime(result.cachePath)
    else:
      result.lastModTime = getLastModificationTime(result.sourcePath)
  of pkStatic:
    result.lastModTime = getLastModificationTime(result.staticPath)
  else:
    discard

  result.requestPath = path

proc resolvePage*(conf: Configuration, request: Request): Page {.gcsafe.} =
  result = conf.resolvePage(request.path)

proc findPagesAtPath*(conf: Configuration, path: string): seq[Page] {.gcsafe.} =
  for (content, metadata) in walkPagePattern(path):
    let page = conf.resolvePage(content)
    result.add page

proc fetchMetadata*(page: Page): PageMetadata =
  case page.kind
  of pkSource:
    try:
      var metadata_stream = openFileStream(page.sourcePath.metadata)
      let metadata_json = loadToJson(metadata_stream)
      metadata_stream.close()
      result = initMetadata(metadata_json[0])
    finally:
      discard
  else:
    discard

proc generate*(page: Page, metadata: PageMetadata): string {.gcsafe.} =
  echo fmt"generating page contents for request: {page.requestPath}"

  var content: string
  try:
    var content_stream = openFileStream(page.sourcePath.content)
    content = content_stream.readAll()
    content_stream.close()
  finally:
    result = ""

  var generated_html: string
  var generator: RstGenerator
  try:
    generator.initRstGenerator(outHtml, defaultConfig(), page.sourcePath.content, {})
    var has_toc = false
    let rst_data = rstParse(content, page.sourcePath.content, 1, 1, has_toc, {})
    {.cast(gcsafe).}:
      generator.renderRstToOut(rst_data, generated_html)
      result = deepCopy(generated_html)
  finally:
    generated_html = """<html><head><title>error!</title></head><body><div>failed to render page!</div></body></html>"""

proc updateCache*(page: Page, contents: string): bool =
  result = false
  let stream = newFileStream(page.cachePath, fmWrite)
  if not stream.isNil():
    stream.write(contents)
    stream.close()
    result = true
