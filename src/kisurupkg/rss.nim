
# =======
# Imports
# =======

# Standard Library Imports
import os
import times
import logging
import options
import strtabs
import xmltree
import algorithm
import strformat

# Third Party Package Imports
import uuids

# Package Imports
import "defaults.nim"
import "models.nim"
import "webpage.nim"
import "page/filepath.nim"

# =========
# Constants
# =========
const
  Default_Version = "2.0"
  Tag_Channel = "channel"

# =========
# Functions
# =========

proc postDateCompare(a: Webpage, b: Webpage): int =
  #[
    result < 0 :: a > b
    result = 0 :: a = b
    result > 0 :: a < b
  ]#
  var a_date, b_date: DateTime

  let a_meta = a.fetchMetadata()
  if a_meta.date.isSome():
    let a_date_str = a_meta.date.get()
    a_date = parse(a_date_str, Default_Metadata_PostDate_Formatter)

  let b_meta = b.fetchMetadata()
  if b_meta.date.isSome():
    let b_date_str = b_meta.date.get()
    b_date = parse(b_date_str, Default_Metadata_PostDate_Formatter)

  if a_date < b_date:
    result = -1

  if a_date == b_date:
    result = 0

  if a_date > b_date:
    result = 1

proc generateRssItem(conf: Configuration, page: Webpage): XmlNode =
  let metadata = page.fetchMetadata()

  info(fmt"metadata: {metadata}")

  # check to see if the post is valid for creating an entry

  result = <>item()

  let title_node = newText(metadata.title)
  let title = <>title(title_node)
  result.add(title)

  var summary_text = ""
  if metadata.summary.isSome():
    summary_text = metadata.summary.get()

  let description_node = newText(summary_text)
  let description = <>description(description_node)
  result.add(description)

  let link_url = conf.expandPageUrl(page)
  let link_node = newText(fmt"{link_url}")
  let link = <>link(link_node)
  result.add(link)

  var published_date_str = ""
  if metadata.date.isSome():
    published_date_str = metadata.date.get()

  if len(published_date_str) > 0:
    let published_date = parse(published_date_str, Default_Metadata_PostDate_Formatter)
    let published_time = initDuration(hours = 6, minutes = 6, seconds = 6)
    let adjusted_date = published_date+published_time
    let formatted_pub_date = adjusted_date.format(Default_PubDate_DateTime_Formatter)

    let pubdate_text = newText(formatted_pub_date)
    let pubdate = <>pubDate(pubdate_text)
    result.add(pubdate)


proc generateRssFeedBody(conf: Configuration, pages: seq[Webpage]): XmlNode =
  result = <>rss(version=Default_Version)

  let title_text = newText("Samantha Demi's Blog")
  var title = <>title(title_text)

  let description_text = newText("Blog Feed")
  var description = <>description(description_text)

  let link_text = newText(fmt"{conf.baseUrl}")
  var link = <>link(link_text)

  var language_text = newText("en-us")
  var language = <>language(language_text)

  var last_build_date_date = now()
  var last_build_date_text_str = last_build_date_date.format(Default_PubDate_DateTime_Formatter)
  var last_build_date_text = newText(last_build_date_text_str)
  var last_build_date = <>lastBuildDate(last_build_date_text)

  var generator_text = newText(fmt"Built with Nim: {NimVersion}, using 'xmltree' module of the standard library.")
  var generator = <>generator(generator_text)

  let elements = [
    # Required Elements
    title, description, link,

    # Optional Elements
    language, last_build_date, generator
  ]

  var channel = newXmlTree(Tag_Channel, elements, newStringTable())
  result.add(channel)

  for page in pages:
    let item = conf.generateRssItem(page)
    # echo $item
    channel.add(item)


proc generateRssFeed*(conf: Configuration): string =
  let target_dir =  conf.scanDirForRssFeed / "*"
  echo fmt"origin: {conf.sourcePath}"
  echo fmt"target: {target_dir}"

  var pages = newSeq[Webpage]()

  let origin = some(conf.sourcePath)
  let file = target_dir.initFilePath(origin) #(origin: some(conf.sourcePath), directory: conf.scanDirForRssFeed, filename: "*", extensions: @["*"])
  for filepath in file.searchOrigin(origin, useGlobExt = true):
    let page_path = filepath.base(dropOrigin=true).dot(FileExt_Html)
    echo (fmt"found page: {page_path}")
    let page = conf.resolvePath(page_path)
    pages.add(page)
  # var pages = conf.findPagesAtPath(target_dir)
  # echo $pages
  pages.sort(postDateCompare, SortOrder.Descending)

  let body = conf.generateRssFeedBody(pages)

  result = fmt"{xmlHeader}{$body}"
