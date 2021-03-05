
# =======
# Imports
# =======

import unittest

# Standard Library Imports
import os

# Third Party Package Imports

# Package Imports
import kisurupkg/[ models, configuration, rss ]

# =========
# Constants
# =========

const
  Configuration_Path = parentDir(currentSourcePath()) /../ "content" / "pewpewthespells.toml"

# =====
# Tests
# =====

suite "RSS":

  test "Generate":
    let conf = initConfiguration(Configuration_Path)

    let rss = conf.generateRssFeed()
    echo $rss
