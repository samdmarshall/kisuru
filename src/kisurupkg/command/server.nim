
# =======
# Imports
# =======

# Standard Library Imports
import os
import uri
import json
import asyncdispatch

# Third Party Package Imports
import jester
import "../../../httpauth/httpauth.nim"
#import httpauth

# Package Imports
#import kisurupkg / [ users, twitter ]
import "../users.nim"
import "../twitter.nim"
#import kisurupkg/config
import "../config.nim"

# =========
# Functions
# =========


# ==========
# Main Entry
# ==========

#
#
proc parseServerCommand*(config: Configuration, args: seq[string]): bool =
  var auth = prepareUserDatabase()

  # ============
  # Routing Maps
  # ============

  router Authentication:
    post "/login":
      auth.headers_hook(request.headers)
      try:
        auth.login(@"username", @"password")
        resp Http200
      except LoginError:
        resp Http401

    get "/logout":
      try:
        auth.logout()
        resp Http200
      except AuthError:
        resp Http401

  router Actions:
    post "/new":
      let payload = parseJson(request.body)
      resp payload

    post "/twitter-gif":
      handleTwitterGif(request)
      resp Http200

    get "/@user/latest":
      let user = @"user"
      resp "latest from user: " & user

    get "/@user/count":
      let user = @"user"
      resp "count from user (" & user & ") is: "

  router Interface:
    extend Authentication, ""
    extend Actions, ""

  router Kisuru:
    extend Interface, "/api/v1"

  var config = newSettings()
  var website = initJester(Kisuru, config)
  website.serve()

