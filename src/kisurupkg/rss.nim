
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
import "page/metadata.nim"

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

proc generateRssItem(conf: Configuration, page: Webpage): tuple[published: bool, node: XmlNode] =
  let metadata = page.fetchMetadata()

  info(fmt"metadata: {metadata}")

  # check to see if the post is valid for creating an entry

  var node = <>item()

  if metadata.isPublished():
    let title_node = newText(metadata.title)
    let title = <>title(title_node)
    node.add(title)

    var summary_text = ""
    if metadata.summary.isSome():
      summary_text = metadata.summary.get()

    let description_node = newText(summary_text)
    let description = <>description(description_node)
    node.add(description)

    let link_url = conf.expandPageUrl(page)
    let link_node = newText(fmt"{link_url}")
    let link = <>link(link_node)
    node.add(link)

    var published_date_str = ""
    if metadata.date.isSome():
      published_date_str = metadata.date.get()

    var published_time_str = ""
    if metadata.time.isSome():
      published_time_str = metadata.time.get()

    var published_date: DateTime
    if len(published_date_str) > 0:
      published_date = parse(published_date_str, Default_Metadata_PostDate_Formatter)

    var published_time = initDuration(hours = 6, minutes = 6, seconds = 6)
    if len(published_time_str) > 0:
      let time = parse(published_time_str, Default_Metadata_PostTime_Formatter)
      published_time = initDuration(hours = int(time.hour()), minutes = int(time.minute()), seconds = int(time.second()))

    let date = published_date+published_time
    let formatted_pub_date = date.format(Default_PubDate_DateTime_Formatter)

    let utc_offset = date.utcOffset
    let utc_offset_time = initDuration(seconds = utc_offset)
    let utc_offset_parts = toParts(utc_offset_time)
    let utc_offset_symbol =
      if utc_offset < 0: "+"
      elif utc_offset > 0: "-"
      else: "+"
    let pubdate_text = newText(fmt"{formatted_pub_date} {utc_offset_symbol}{utc_offset_parts[Hours]:02d}{utc_offset_parts[Minutes]:02d}")
    let pubdate = <>pubDate(pubdate_text)
    node.add(pubdate)

  result = (metadata.isPublished(), node)


proc generateRssFeedBody(conf: Configuration, pages: seq[Webpage]): XmlNode =
  var rss_attrs = {"version": Default_Version, "xmlns:atom": "http://www.w3.org/2005/Atom"}.toXmlAttributes
  result = newXmlTree("rss", [], rss_attrs)
  # result = <>rss(version=Default_Version, `xmlns:atom`=)

  let title_text = newText("Samantha Demi's Blog")
  var title = <>title(title_text)

  let description_text = newText("Blog Feed")
  var description = <>description(description_text)

  let link_text = newText(fmt"{conf.baseUrl}")
  var link = <>link(link_text)

  var language_text = newText("en-us")
  var language = <>language(language_text)

  var last_build_date_date = now()
  let utc_offset = last_build_date_date.utcOffset
  let utc_offset_time = initDuration(seconds = utc_offset)
  let utc_offset_parts = toParts(utc_offset_time)
  let utc_offset_symbol =
    if utc_offset < 0: "+"
    elif utc_offset > 0: "-"
    else: "+"
  var last_build_date_text_str = last_build_date_date.format(Default_PubDate_DateTime_Formatter)
  var last_build_date_text = newText(fmt"{last_build_date_text_str} {utc_offset_symbol}{utc_offset_parts[Hours]:02d}{utc_offset_parts[Minutes]:02d}")
  var last_build_date = <>lastBuildDate(last_build_date_text)

  var generator_text = newText(fmt"Built with Nim: {NimVersion}, using 'xmltree' module of the standard library.")
  var generator = <>generator(generator_text)

  var atom_attrs = {"href": fmt"{conf.baseUrl}/feed.xml", "rel": "self", "type": "application/rss+xml"}.toXmlAttributes
  var atom = newXmlTree("atom:link", [], atom_attrs)

  let elements = [
    # Required Elements
    title, description, link,

    # Optional Elements
    language, last_build_date, generator,

    atom
  ]

  var channel = newXmlTree(Tag_Channel, elements, newStringTable())
  result.add(channel)

  for page in pages:
    let (published, node) = conf.generateRssItem(page)
    if published:
      channel.add(node)


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
