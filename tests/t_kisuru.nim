# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import os
import streams
import parseutils

import kisurupkg/[ defaults ]


const
  MetadataSep = "---"

suite "paths":
  test "compare":
    discard


suite "parsing":
  test "embedded-metadata":
    let path = getCurrentDir() / "tests" / "assets" / "test.rst"

    var content_stream: Stream
    try:
      content_stream = openFileStream(path)
      let contents = content_stream.readAll()
      var index: int = 0

      var start_token: string
      index = parseUntil(contents, start_token, MetadataSep)
      let start_index = index + len(MetadataSep)
      echo start_index
      echo start_token
      echo "----------------------------------"

      var metadata_token: string
      index = parseUntil(contents, metadata_token, "---", start=start_index)
      let end_index = start_index + index

      echo end_index
      echo metadata_token
      echo "----------------------------------"

      let body_index = start_index + (end_index + len(MetadataSep))
      let body = contents[body_index..contents.high]

      echo body_index
      echo body
    finally:
      content_stream.close()
