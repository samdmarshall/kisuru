
# =======
# Imports
# =======

# Standard Library Imports
import options
import htmlgen
import strformat

# Third Party Package Imports

# Package Imports
import "models.nim"
import "webpage.nim"
import "page/metadata.nim"

# =========
# Functions
# =========

proc renderTemplate*(page: Webpage): string =
  let metadata = page.fetchMetadata()

  let published_warning =
    if not metadata.isPublished(): """"""
    else: """"""

  let header_contents =
    if metadata.isHeaderDisabled(): """"""
    else: fmt"""<title>{metadata.title}</title><link rel="stylesheet" type="text/css" href="/nimdoc.out.css">"""

  let footer_contents =
    if metadata.isFooterDisabled(): """"""
    else: """"""

  let body_contents = page.generate(metadata)
  result = html(
    head(header_contents),
    body(published_warning, fmt"""<div id="documentId" class="document"><div class="container"><h1 class="title">{metadata.title}</h1>{body_contents}</div></div>"""),
    footer(footer_contents)
    )
  echo result
