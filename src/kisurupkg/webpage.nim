
# =======
# Imports
# =======

# Standard Library Imports
import os
import times
import logging
import options
import streams
import sequtils
import strutils
import strformat

import packages/docutils/rst
import packages/docutils/rstgen

# Third Party Package Imports
import jester

# Package Imports
import "models.nim"
import "defaults.nim"
import "page/metadata.nim"
import "page/filepath.nim"
#import kisurupkg/[ models, defaults ]
#import kisurupkg/page/[ metadata ]

# =========
# Functions
# =========

iterator searchOrigin*(path: FilePath, origin: Option[string] = none(string), useGlobExt: bool = false): FilePath =
  var pattern_base = $path
  if useGlobExt:
    pattern_base = path.base(dropOrigin=true).dot("*")

  var pattern = pattern_base
  if origin.isSome():
    let origin_value = origin.get()
    if origin_value.len > 0:
      pattern = origin_value / pattern_base

  var results = newSeq[FilePath]()
  for match in walkFiles(pattern):
    let filepath = initFilePath(match, origin)
    info(fmt"pattern match: {match}")
    results.add filepath

  var unique_files = deduplicate(results.mapIt(it.base()))
  for unique_file in unique_files:
    var (dir, name, ext) = unique_file.splitFile()
    if origin.isSome():
      let origin_value = origin.get()
      if origin_value.len > 0 and dir.isRelativeTo(origin_value):
        dir = dir.relativePath(origin_value)
    let file = results.anyIt(it.base() == unique_file)
    let matched_files = results.filterIt(it.base() == unique_file)
    var found_extensions = newSeq[string]()
    for match in matched_files:
      found_extensions.insert map(match.extensions, normExt)
    if not found_extensions.contains(ext):
      if ext.len > 1:
        name = name & ExtSep & normExt(ext)
    let merged_filepath = FilePath(origin: origin, directory: "/" / dir, filename: name, extensions: found_extensions)
    yield merged_filepath

proc fileExists*(path: FilePath, origin: Option[string] = none(string), useGlobExt: bool = false): bool =
  var matches = newSeq[bool]()
  notice(fmt"finding matches for: {path} in: {origin}")
  for file in path.searchOrigin(origin, useGlobExt):
    notice(fmt"found: {file}")
    debug(fmt"{file} == {path}")
    var did_find_match = false
    if useGlobExt:
      did_find_match = useGlobExt and file == path
    else:
      did_find_match = file === path
    matches.add did_find_match
  notice(fmt"results: {matches}")
  if matches.len > 0:
    result = matches.allIt(it)
  else:
    result = false

# =================
# Webpage Functions
# =================

proc isCached*(page: Webpage): bool =
  case page.kind
  of wpDynamic:
    let path_to_cached_file = $page.cachePath
    notice(fmt"looking up file: {path_to_cached_file}")
    result = fileExists(path_to_cached_file)
  else:
    result = false

proc isCacheOutdated*(page: Webpage): bool =
  case page.kind
  of wpDynamic:
    let source_last_mod = page.sourcePath.getLastModificationTime()
    let cache_last_mod = page.cachePath.getLastModificationTime()
    let cache_is_outdated = cache_last_mod < source_last_mod
    result = cache_is_outdated
  else:
    result = false

proc expandWebpagePath*(conf: Configuration, strpath: string): string =
  let is_directory = strpath.endsWith(DirSep)
  if is_directory:
    # map to the directory's "index.html"
    result = strpath / IndexPageName.dot(FileExt_Html)
    notice(fmt"resolving {strpath} -> {result}")
  else:
    result = strpath

proc expandPageUrl*(conf: Configuration, page: Webpage): string =
  # let relative_path = relativePath(page.path, conf.sourcePath)
  result = fmt"{conf.baseUrl}/{page.path}"
  notice(fmt"composing full url: {result} -> ({page})")

proc resolvePath*(conf: Configuration, filepath: string): Webpage =
  let full_filepath = conf.expandWebpagePath(filepath)
  notice(fmt"requesting full path: {full_filepath}")
  let path = initFilePath(full_filepath)

  let is_in_cache = path.fileExists(some(conf.cachePath))
  let is_in_source = path.fileExists(some(conf.sourcePath), useGlobExt = true)
  let is_in_static = path.fileExists(some(conf.staticPath))

  notice(fmt"found in cache: {is_in_cache}")
  notice(fmt"found in source: {is_in_source}")
  notice(fmt"found in static: {is_in_static}")

  let is_dynamic_content = (is_in_cache and is_in_source) or (is_in_source)
  let is_stale_content = (is_in_cache and (not is_in_source))
  let is_static_content = (is_in_static)
  let is_error_content = ((not is_static_content) and (not is_dynamic_content)) or (is_stale_content)

  notice(fmt"is dynamic: {is_dynamic_content}")
  notice(fmt"is stale: {is_stale_content}")
  notice(fmt"is static: {is_static_content}")
  notice(fmt"is error: {is_error_content}")

  if is_dynamic_content:
    var results = toSeq(path.searchOrigin(some(conf.sourcePath), useGlobExt = true))
    var source = results[0]
    source.origin = some(conf.sourcePath)

    var cache = deepCopy(path)
    cache.origin = some(conf.cachePath)

    result = Webpage(path: path, kind: wpDynamic, sourcePath: source, cachePath: cache)

  if is_static_content:
    var static_page = deepCopy(path)
    static_page.origin = some(conf.staticPath)
    result = Webpage(path: path, kind: wpStatic, staticPath: static_page)

  if is_error_content:
    result = Webpage(path: path, kind: wpInvalid)


proc resolvePath*(conf: Configuration, request: Request): Webpage =
  let requested_file = request.path
  notice(fmt"requesting path: {requested_file}")
  result = conf.resolvePath(requested_file)


proc fetchMetadata*(page: Webpage): PageMetadata =
  case page.kind
  of wpDynamic:
    let metadata_path = page.sourcePath.getMetadataPath()
    result = initMetadata(metadata_path)
  else:
    discard

proc generate*(page: Webpage, metadata: PageMetadata): string {.gcsafe.} =
  echo fmt"generating page contents for request: {page.path}"

  let content_path = page.sourcePath.getContentPath()

  var content: string
  try:
    var content_stream = openFileStream(content_path)
    content = content_stream.readAll()
    content_stream.close()
  finally:
    result = ""

  var generated_html: string
  var generator: RstGenerator
  try:
    generator.initRstGenerator(outHtml, defaultConfig(), content_path, {})
    var has_toc = false
    let rst_data = rstParse(content, content_path, 1, 1, has_toc, {})
    {.cast(gcsafe).}:
      generator.renderRstToOut(rst_data, generated_html)
      result = deepCopy(generated_html)
  finally:
    generated_html = """<html><head><title>error!</title></head><body><div>failed to render page!</div></body></html>"""

proc updateCache*(page: Webpage, contents: string): bool =
  result = false
  let cache_path = $page.cachePath
  let stream = newFileStream(cache_path, fmWrite)
  if not stream.isNil():
    stream.write(contents)
    stream.close()
    result = true
