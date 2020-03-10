
import asyncdispatch

import httpclient
import streams
import tables
import json
import uri
import os

import strformat
import strscans


import jester


#
#
proc authenticateUser(user: string): bool =
  result = (user == "demi")


#
#
router Authentication:
  post "/login":
    let payload = parseJson(request.body)
    let user = payload["user"].getStr()
    if authenticateUser(user):
      resp Http200
    else:
      resp Http401

  get "/logout":
    let payload = parseJson(request.body)
    let user = payload["user"].getStr()
    if authenticateUser(user):
      resp Http200
    else:
      resp Http401

#
#
router Actions:
  post "/new":
    let payload = parseJson(request.body)

    let user = payload["user"].getStr()
    let url = parseUri(payload["url"].getStr())

    resp Http200


  post "/twitter-gif":
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

    resp Http200


  get "/@user/latest":
    let user = @"user"
    resp "latest from user: " & user

  get "/@user/count":
    let user = @"user"
    resp "count from user (" & user & ") is: "

#
#
router Interface:
  extend Authentication, ""
  extend Actions, ""

#
#
router Kisuru:
  extend Interface, "/api/v1"


#
#
proc main() =
  var config = newSettings()
  var website = initJester(Kisuru, config)
  website.serve()

#[
proc parseWebsite() =
  let target_url = "https://twitter.com/_tamlu/status/1236471604848230402"

  var driver = newWebDriver()
  var session = driver.createSession()
  session.navigate(target_url)
  var div_elements = session.findElements("div", TagNameSelector)
  for div_element in div_elements.items():
    let name = div_element.getAttribute("aria-label")
    if name == "Embedded Video":
      div_element.click()
      break
  let video_element = session.findElement("video", TagNameSelector)
  if not video_element.isSome():
    raise newException(OSError, "no video tag found!")
  let video_tag = video_element.get()
  let video_url = video_tag.getAttribute("src")

  echo video_url

  var client = newHttpClient()
  let response = client.get(video_url)

  let date = now()
  let url = parseUri(video_url)
  var path = getTempDir() / getAppFilename().extractFilename() /
      fmt"{date.year}.{date.month}.{date.monthday}@{date.hour}:{date.minute}:{date.second}" /
      url.hostname / url.path.extractFilename()
  if not existsFile(path):
    createDir(path.parentDir())
  var video_file = newFileStream(path, fmReadWrite)
  video_file.write(response.bodyStream.readAll())
  video_file.close()

  echo path
]#


#
#
when isMainModule:
  main()
  #parseWebsite()
