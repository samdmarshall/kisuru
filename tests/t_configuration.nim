
# =======
# Imports
# =======

import unittest

# Standard Library Imports
import os
import uri

# Third Party Package Imports

# Package Imports
import kisurupkg/[ models, configuration ]

# =========
# Constants
# =========
const
  Test_Configuration_Path = parentDir(currentSourcePath()) / "assets" / "example-config.toml"

# =====
# Tests
# =====

suite "Configuration":

  setup:
    let root = parentDir(Test_Configuration_Path)

  test "Defaults":
    let conf = defaultConfiguration(Test_Configuration_Path)

    let sourcePath = root / "public"
    let cachePath = root / "cache"
    let staticPath = root / "static"

    let scanDirForRssFeed = sourcePath / "blog"

    let baseUrl = "https://example.com"

    check:
      conf.jesterPort == Port(5000)

    check:
      cmpPaths(conf.sourcePath, sourcePath) == 0

    check:
      cmpPaths(conf.cachePath, cachePath) == 0

    check:
      cmpPaths(conf.staticPath, staticPath) == 0

    check:
      conf.headerTemplate == "header.template"

    check:
      conf.footerTemplate == "footer.template"

    check:
      cmpPaths(conf.scanDirForRssFeed, scanDirForRssFeed) == 0

    check:
      conf.baseUrl == baseUrl
      parseUri(conf.baseUrl) == parseUri(baseUrl)



  test "Initialize":
    let conf = initConfiguration(Test_Configuration_Path)

    let sourcePath = root / "source-dir"
    let cachePath = root / "cache-dir"
    let staticPath = root / "static-dir"

    let scanDirForRssFeed = sourcePath / "blog-dir"

    let baseUrl = "https://example-website.com"


    check:
      conf.jesterPort == Port(8080)

    check:
      cmpPaths(conf.sourcePath, sourcePath) == 0

    check:
      cmpPaths(conf.cachePath, cachePath) == 0

    check:
      cmpPaths(conf.staticPath, staticPath) == 0

    check:
      conf.headerTemplate == "header-template.txt"

    check:
      conf.footerTemplate == "footer-template.txt"

    check:
      cmpPaths(conf.scanDirForRssFeed, scanDirForRssFeed) == 0

    check:
      conf.baseUrl == baseUrl
      parseUri(conf.baseUrl) == parseUri(baseUrl)
