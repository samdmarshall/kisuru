
# =======
# Imports
# =======

# Standard Library Imports
import os
import times
import options
import strtabs
import xmltree
import algorithm
import strformat

# Third Party Package Imports

# Package Imports
import "defaults.nim"
import "models.nim"
import "page.nim"

# =========
# Constants
# =========
const
  Default_Version = "2.0"
  Tag_Channel = "channel"

# =========
# Functions
# =========

proc postDateCompare(a: Page, b: Page): int =
  #[
    result < 0 :: a > b
    result = 0 :: a = b
    result > 0 :: a < b
  ]#
  let a_meta = a.fetchMetadata()
  let a_date = a_meta.date.toDate()

  let b_meta = b.fetchMetadata()
  let b_date = b_meta.date.toDate()

  if a_date < b_date:
    result = -1

  if a_date == b_date:
    result = 0

  if a_date > b_date:
    result = 1

proc generateRssItem(conf: Configuration, page: Page): XmlNode =
  let metadata = page.fetchMetadata()

  # check to see if the post is valid for creating an entry

  result = <>item()

  let title_node = newText(metadata.title)
  let title = <>title(title_node)
  result.add(title)

  let description_node = newText(metadata.summary.get())
  let description = <>description(description_node)
  result.add(description)

  let link_url = page.expandPageUrl(conf)
  let link_node = newText(fmt"{link_url}")
  let link = <>link(link_node)
  result.add(link)


proc generateRssFeedBody(conf: Configuration, pages: seq[Page]): XmlNode =
  result = <>rss(version=Default_Version)

  var title = <>title()
  var description = <>description()
  var link = <>link()

  var channel = newXmlTree(Tag_Channel, [title, description, link], newStringTable())
  result.add(channel)

  for page in pages:
    let item = conf.generateRssItem(page)
    # echo $item
    channel.add(item)


proc generateRssFeed*(conf: Configuration): string =
  echo conf.scanDirForRssFeed / "*"
  var pages = conf.findPagesAtPath(conf.scanDirForRssFeed / "*")
  echo $pages
  pages.sort(postDateCompare, SortOrder.Descending)

  let body = conf.generateRssFeedBody(pages)

  result = fmt"{xmlHeader}{$body}"
