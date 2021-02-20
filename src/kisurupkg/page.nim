# =======
# Imports
# =======

# Standard Library Imports
import os
import json
import times
import streams
import strtabs
import sequtils
import strutils
import strformat

import packages.docutils.rst
import packages.docutils.rstgen

# Third Party Package Imports
import yaml
import jester

# Package Imports
import "models.nim"
import "defaults.nim"
#import kisurupkg/[ models ]

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

proc resolvePage*(conf: Configuration, request: Request): Page {.gcsafe.} =
  let static_path = conf.staticPath / request.path
  if fileExists(static_path):
    result = Page(kind: pkStatic)
    result.staticPath = static_path
  else:
    result = Page(kind: pkSource)

    let path_no_ext = changeFileExt(request.path, "")
    echo fmt"searching for page at path: {path_no_ext}"
    let pattern = conf.sourcePath / path_no_ext & ".*"
    for source in walkPagePattern(pattern):
      let found_path = relativePath(changeFileExt(source.content, ""), conf.sourcePath)
      echo fmt"found: {found_path}"
      if cmpPaths(relativePath(path_no_ext, "/"), found_path) == 0:
        result.sourcePath = source
        result.cachePath = conf.cachePath / request.path
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

  result.requestPath = request.path


proc generate*(page: Page): string =
  echo fmt"generating page contents for request: {page.requestPath}"
  var content_stream = newFileStream(page.sourcePath.content)
  let content = content_stream.readAll()
  content_stream.close()

  var metadata_stream = newFileStream(page.sourcePath.metadata)
  let metatdata = loadToJson(metadata_stream)
  metadata_stream.close()

  var generator: RstGenerator
  generator.initRstGenerator(outHtml, defaultConfig(), page.sourcePath.content, {})
  var has_toc = false
  let rst_data = rstParse(content, page.sourcePath.content, 1, 1, has_toc, {})

  var generated_html = ""
  {.cast(gcsafe).}:
    generator.renderRstToOut(rst_data, generated_html)
    result = deepCopy(generated_html)

proc updateCache*(page: Page, contents: string): bool =
  result = false
  let stream = newFileStream(page.cachePath, fmWrite)
  if not stream.isNil():
    stream.write(contents)
    stream.close()
    result = true
