
# =======
# Imports
# =======

import unittest

# Standard Library Imports

# Third Party Package Imports

# Package Imports
import kisurupkg/[ defaults ]


# =====
# Tests
# =====

#[
const
  MetadataSep = "---"

suite "Parsing":
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
      # echo start_index
      # echo start_token
      # echo "----------------------------------"

      var metadata_token: string
      index = parseUntil(contents, metadata_token, "---", start=start_index)
      let end_index = start_index + index

      # echo end_index
      # echo metadata_token
      # echo "----------------------------------"

      let body_index = start_index + (end_index + len(MetadataSep))
      let body = contents[body_index..contents.high]

      # echo body_index
      # echo body
    finally:
      content_stream.close()

]#
