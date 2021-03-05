
# # =======
# # Imports
# # =======

# # Standard Library Imports
# import os
# import json
# import times
# import streams
# import strutils
# import strformat

# import packages/docutils/rst
# import packages/docutils/rstgen

# # Third Party Package Imports
# import yaml
# import jester

# # Package Imports
# import "defaults.nim"
# import "models.nim"
# import "configuration.nim"

# # =========
# # Constants
# # =========

# const
#   IndexPageName = "index"

# # =====
# # Types
# # =====

# type

#   PageKind* = enum
#     pUnknown,
#     pDynamic,
#     pStatic,
#     pError

#   PageFile* = object
#     dir*: string
#     name*: string
#     extensions*: seq[string]

#   Page* = object
#     kind*: PageKind
#     file*: PageFile


#   PageMetadata* = object
#     # rss fields
#     title*: string
#     summary*: Option[string]
#     date*: Option[string]
#     # private fields, use methods for these
#     published: bool
#     root: Option[bool]
#     disableheader: Option[bool]
#     disablefooter: Option[bool]


# # =========
# # Functions
# # =========

# # =================
# # Utility Functions
# # =================

# proc normExt(ext: string): string =
#   #[
#     For: ".rst" -> "rst"

#     For: "rst" -> "rst"
#   ]#
#   let origin = ext.low
#   let last = ext.high
#   let offset = ext.find(ExtSep, origin, last)
#   let skip = offset + origin
#   if skip == 0:
#     let start = skip + 1
#     result = ext[start..last]
#   else:
#     result = ext

# proc dot*(name: string, ext: string): string =
#   if name.len > 0:
#     result = name & ExtSep & ext

# # ==================
# # PageFile Functions
# # ==================

# proc initPageFile*(filepath: string): PageFile =
#   let (dir, name, ext) = filepath.splitFile()
#   result = PageFile(dir: dir, name: name, extensions: @[normExt(ext)])

# proc `$`*(page: PageFile): string =
#   result = page.dir / page.name.dot(page.extensions.join("."))

# proc `===`*(a, b: PageFile): bool =
#   let dirs_match = a.dir == b.dir
#   let names_match = a.name == b.name
#   let exts_match = a.extensions == b.extensions
#   result = dirs_match and names_match and exts_match

# proc `==`*(a, b: PageFile): bool =
#   let dirs_match = a.dir == b.dir
#   let names_match = a.name == b.name
#   result = dirs_match and names_match

# iterator filePaths*(page: PageFile): string =
#   for ext in page.extensions:
#     yield page.dir / page.name.dot(ext)

# proc getLastModificationTime*(page: PageFile): Time =
#   result = fromUnix(0)
#   for file in page.filePaths():
#     let mod_time = file.getLastModificationTime()
#     if mod_time < result:
#       result = mod_time

# proc isOutput*(file: PageFile): bool =
#   result = file.extensions.contains(FileExt_Html)

# proc isInput*(file: PageFile): bool =
#   result = file.extensions.contains(FileExt_Rst) and file.extensions.contains(FileExt_Yaml)

# proc getMetadataPath*(file: PageFile): string =
#   if file.extensions.contains(FileExt_Yaml):
#     result = file.dir / file.name.dot(FileExt_Yaml)

# proc getContentPath*(file: PageFile): string =
#   if file.extensions.contains(FileExt_Rst):
#     result = file.dir / file.name.dot(FileExt_Rst)

# proc findPageFiles(parent: string, file: PageFile): PageFile =
#   result.dir = file.dir
#   result.name = file.name
#   if result.name.len > 0:
#     for file in walkFiles(parent / result.dir / result.name.dot("*")):
#       let (_, _, ext) = file.splitFile()
#       result.extensions.add(normExt(ext))
#     if result.extensions.len == 0:
#       result = PageFile()

# proc foundInDirectory*(file: PageFile, parent: string, allowExtChange: bool = false): bool =
#   let found = parent.findPageFiles(file)
#   if allowExtChange:
#     result = (file == found)
#   else:
#     result = (file === found)

# # ====================
# # PageMetadata Methods
# # ====================

# proc initMetadata*(data: JsonNode): PageMetadata =
#   result.date = some(now().format("MMMM dd, yyyy"))
#   result.summary = some("website page")
#   result.disableheader = some(false)
#   result.disablefooter = some(false)
#   result.root = none(bool)
#   result.published = false
#   result = data.to(PageMetadata)

# proc isPublished*(metadata: PageMetadata): bool =
#   return metadata.published

# proc isHeaderDisabled*(metadata: PageMetadata): bool =
#   result = false
#   if metadata.disableheader.isSome():
#     result = metadata.disableheader.get()

# proc isFooterDisabled*(metadata: PageMetadata): bool =
#   result = false
#   if metadata.disablefooter.isSome():
#     result = metadata.disablefooter.get()

# proc isRoot*(metadata: PageMetadata): bool =
#   result = false
#   if metadata.root.isSome():
#     result = metadata.root.get()

# proc toDate*(date: string): DateTime =
#   result = parse(date, "MMMM d, YYYY")

# proc toDate*(date: Option[string]): DateTime =
#   if date.isSome():
#     let date_string = date.get()
#     result = date_string.toDate()

# # ==============
# # Page Functions
# # ==============

# proc expandPath*(page: Page, conf: Configuration): string =
#   case page.kind
#   of pDynamic:
#     let found_in_cache = page.file.foundInDirectory(conf.cachePath)
#     if found_in_cache:
#       result = conf.cachePath / $(page.file)
#   of pStatic:
#     result = conf.staticPath / $(page.file)
#   else:
#     discard

# proc getCache*(page: Page, conf: Configuration): PageFile =
#   case page.kind
#   of pDynamic:
#     if page.file.isInput():
#       result = conf.cachePath.findPageFiles(page.file)
#   else:
#     discard

# proc getSource*(page: Page, conf: Configuration): PageFile =
#   case page.kind
#   of pDynamic:
#     if page.file.isOutput():
#       result = conf.sourcePath.findPageFiles(page.file)
#   else:
#     discard

# proc isCached*(conf: Configuration, page: Page): bool =
#   case page.kind
#   of pDynamic:
#     let path = page.expandPath(conf)
#     result = fileExists(path)
#   else:
#     result = false

# proc isCacheOutdated*(conf: Configuration, page: Page): bool =
#   case page.kind
#   of pDynamic:
#     var alternate =
#       if page.file.isInput():page.getCache(conf)
#       else: page.getSource(conf)
#     let alternate_last_mod = alternate.getLastModificationTime()
#     let page_last_mod = page.file.getLastModificationTime()
#     if page.file.isOutput():
#       result = (alternate_last_mod > page_last_mod)
#     else:
#       result = (page_last_mod > alternate_last_mod)
#   else:
#     result = false

# # iterator walkSubpattern(conf: Configuration, dir, name: string): PageFile =
# #   let search_path = dir / name.dot("*")
# #   for parent in @[conf.cachePath, conf.sourcePath, conf.staticPath]:
# #     discard

# # iterator walkPageFiles*(conf: Configuration, filepath: string): Page =
# #   for parent in @[conf.cachePath, conf.sourcePath, conf.staticPath]:
# #     var path_type = pUnknown
# #     if parent == conf.cachePath:
# #       path_type = pCache
# #     if parent == conf.sourcePath:
# #       path_type = pSource
# #     if parent == conf.staticPath:
# #       path_type = pStatic
# #     yield Page(kind: path_type, file: conf.findPageFiles(parent, filepath))

# proc expandWebsitePath(conf: Configuration, filepath: string): string =
#   let is_directory = filepath.endsWith(DirSep)
#   if is_directory:
#     # map to the directory's "index.html"
#     result = filepath / IndexPageName.dot(FileExt_Html)
#     echo fmt"resolving {filepath} -> {result}"
#   else:
#     result = filepath

# proc resolvePath*(conf: Configuration, filepath: string): Page =
#   let full_filepath = conf.expandWebsitePath(filepath)
#   echo fmt"requesting full path: {full_filepath}"
#   result.file = initPageFile(full_filepath)

#   if result.file.foundInDirectory(conf.cachePath):
#     result.kind = pDynamic
#   elif result.file.foundInDirectory(conf.sourcePath, true):
#     result.kind = pDynamic
#   elif result.file.foundInDirectory(conf.staticPath):
#     result.kind = pStatic
#   else:
#     result.kind = pError


# proc resolvePath*(conf: Configuration, request: Request): Page =
#   let requested_file = request.path
#   echo fmt"requesting path: {requested_file}"
#   result = conf.resolvePath(requested_file)


# proc fetchMetadata*(conf: Configuration, page: Page): PageMetadata =
#   case page.kind
#   of pDynamic:
#     let source = page.getSource(conf)
#     let metadata_path = conf.sourcePath / source.getMetadataPath()
#     try:
#       var metadata_stream = openFileStream(metadata_path)
#       let metadata_json = loadToJson(metadata_stream)
#       metadata_stream.close()
#       result = initMetadata(metadata_json[0])
#     finally:
#       discard
#   else:
#     discard

# proc generate*(conf: Configuration, page: Page, metadata: PageMetadata): string {.gcsafe.} =
#   echo fmt"generating page contents for request: {page.file}"

#   let source = page.getSource(conf)
#   let content_path = conf.sourcePath / source.getContentPath()

#   var content: string
#   try:
#     var content_stream = openFileStream(content_path)
#     content = content_stream.readAll()
#     content_stream.close()
#   finally:
#     result = ""

#   var generated_html: string
#   var generator: RstGenerator
#   try:
#     generator.initRstGenerator(outHtml, defaultConfig(), content_path, {})
#     var has_toc = false
#     let rst_data = rstParse(content, content_path, 1, 1, has_toc, {})
#     {.cast(gcsafe).}:
#       generator.renderRstToOut(rst_data, generated_html)
#       result = deepCopy(generated_html)
#   finally:
#     generated_html = """<html><head><title>error!</title></head><body><div>failed to render page!</div></body></html>"""

# proc updateCache*(conf: Configuration, page: Page, contents: string): bool =
#   result = false

#   let cache = page.getCache(conf)
#   let cache_path = conf.cachePath / $cache

#   let stream = newFileStream(cache_path, fmWrite)
#   if not stream.isNil():
#     stream.write(contents)
#     stream.close()
#     result = true
