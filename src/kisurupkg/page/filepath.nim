# =======
# Imports
# =======

# Standard Library Imports
import os
import times
import logging
import options
import sequtils
import strutils
import strformat

# Third Party Package Imports

# Package Imports
import "../models.nim"
import "../defaults.nim"
# import kisurupkg/[ models, defaults ]

# =====
# Types
# =====


# =================
# Utility Functions
# =================

proc normExt*(ext: string): string =
  #[
    For: ".rst" -> "rst"

    For: "rst" -> "rst"
  ]#
  let origin = ext.low
  let last = ext.high
  let offset = ext.find(ExtSep, origin, last)
  let skip = offset + origin
  if skip == 0:
    let start = skip + 1
    result = ext[start..last]
  else:
    result = ext

proc dot*(name: string, ext: string): string =
  result = name
  if name.len > 0:
    result = name & ExtSep & ext


# ==================
# FilePath Functions
# ==================

proc initFilePath*(filepath: string, origin: Option[string] = none(string)): FilePath =
  var (dir, name, ext) = filepath.splitFile()
  if origin.isSome():
    let origin_value = origin.get()
    if origin_value.len > 0 and dir.isRelativeTo(origin_value):
      dir = "/" / dir.relativePath(origin_value)
  dir.normalizePathEnd(true)
  debug("initializing FilePath:" & fmt"""

  origin: {origin}
  directory: {dir}
  filename: {name}
  extensions: {normExt(ext)}""")
  result = FilePath(origin: origin, directory: dir, filename: name, extensions: @[normExt(ext)])

proc base*(path: FilePath, dropOrigin: bool = false): string =
  result = "/" / path.directory / path.filename
  if path.origin.isSome() and (dropOrigin == false):
    let origin_value = path.origin.get()
    if origin_value.len > 0:
      result = path.origin.get() / result

proc `$`*(path: FilePath): string =
  result = path.base().dot(path.extensions.join("|"))

proc `===`*(a, b: FilePath): bool =
  warn("comparing filepaths using ===")
  var origins_match = true
  # let have_origins = (a.origin.isSome() and b.origin.isSome())
  # let lack_origins = (a.origin.isNone() and b.origin.isNone())
  # if have_origins:
  #   origins_match = a.origin.get() == a.origin.get()
  # else:
  #   if not lack_origins:
  #     origins_match = false
  # let a_dir = normalizePathEnd(a.directory)
  # let b_dir = normalizePathEnd(b.directory)
  let dirs_match = normalizedPath(a.directory) == normalizedPath(b.directory)
  warn(fmt"a.filename: {a.filename}")
  warn(fmt"b.filename: {b.filename}")
  let names_match = a.filename == b.filename
  let exts_match = a.extensions == b.extensions
  info(fmt"`===`.result = {dirs_match} | {names_match} | {exts_match}")
  result = origins_match and dirs_match and names_match and exts_match

proc cmpDir*(a, b: string): bool =
  let a_is_root = isRootDir(a)
  let b_is_root = isRootDir(b)
  if a_is_root and b_is_root:
    return true
  else:
    let a_dirs = toSeq(parentDirs(a, fromRoot=true))
    let b_dirs = toSeq(parentDirs(b, fromRoot=true))
    return a_dirs == b_dirs
    # let norm_a = normali

proc `==`*(a, b: FilePath): bool =
  warn("comparing filepaths using ==")
  var origins_match = true
  # debug(fmt"{a} ?? {b}")
  # let have_origins = (a.origin.isSome() and b.origin.isSome())
  # let lack_origins = (a.origin.isNone() and b.origin.isNone())
  # if have_origins:
  #   debug(fmt"a.origin: '{a.origin.get()}'")
  #   debug(fmt"b.origin: '{b.origin.get()}'")
  #   origins_match = a.origin.get() == b.origin.get()
  # else:
  #   if not lack_origins:
  #     origins_match = false
  let dirs_match = normalizedPath(a.directory) == normalizedPath(b.directory)
  let names_match = a.filename == b.filename
  info(fmt"`==`.result = {dirs_match} | {names_match}")
  result = origins_match and dirs_match and names_match

iterator filePaths*(path: FilePath): string =
  for ext in path.extensions:
    yield path.base().dot(ext)

proc getMetadataPath*(path: FilePath): string =
  if path.extensions.contains(FileExt_Yaml):
    result = path.base().dot(FileExt_Yaml)

proc getContentPath*(path: FilePath): string =
  if path.extensions.contains(FileExt_Rst):
    result = path.base().dot(FileExt_Rst)

proc getLastModificationTime*(path: FilePath): Time =
  result = fromUnix(0)
  for file in path.filePaths():
    if fileExists(file):
      let mod_time = file.getLastModificationTime()
      if mod_time < result:
        result = mod_time
