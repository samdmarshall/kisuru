# =======
# Imports
# =======

# Standard Library Imports
import os
import uri
import json
import tables
import streams
import strscans
import strformat
import httpclient

# Third Party Package Imports
import jester

# Package Imports

# =========
# Functions
# =========

#
#
proc handleTwitterGif*(request: Request) =
  let payload = parseJson(request.body)

  let user = payload["user"].getStr()
  let media = payload["media"].getFields()

  let source = parseUri(media["source"].getStr())
  let video = parseUri(media["url"].getStr())
  let name = media["name"].getStr()
  let width = media["width"].getInt()
  let height = media["height"].getInt()
  let looping = media["loop"].getBool()
  let runtime = media["duration"].getStr()
  let frames = media["fps"].getFloat()

  var hours, minutes, seconds: int = 0
  if not scanf(runtime, "?($i:)($i):($i)", hours, minutes, seconds):
    echo "error in parsing duration!"

  let duration = (hours * (60 * 60)) + (minutes * (60)) + seconds + 1

  let save_dir = getTempDir() / getAppFilename().extractFilename()
  if not existsDir(save_dir):
    createDir(save_dir)

  let input_path = save_dir / name.addFileExt("mp4")
  let output_path = save_dir / name.addFileExt("gif")

  let loop_count =
    if looping == true: 0
    else: -1

  let conversion_command = fmt"ffmpeg -t {duration} -i {input_path} -loop {loop_count} -filter_complex '[0:v] scale=width={width}:height={height},fps={frames},split [input][output];[input] palettegen=stats_mode=single [palette];[output][palette] paletteuse=new=1' {output_path}"
  echo conversion_command
  let citation_command = fmt"exiftool -author={$source} {output_path}"
  echo citation_command
