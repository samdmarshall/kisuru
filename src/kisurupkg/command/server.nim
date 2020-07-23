
# =======
# Imports
# =======

# Standard Library Imports
import json
import logging
import asyncdispatch

# Third Party Package Imports
import jester
#import httpauth
import "../../../httpauth/httpauth.nim"

# Local Package Imports
#import kisurupkg / [ config, users, twitter, defaults ]
import "../users.nim"
import "../twitter.nim"
import "../config.nim"
import "../defaults.nim"
#import kisurupkg/command/[ add, remove, search ]
import "../command/add.nim"
import "../command/remove.nim"
import "../command/search.nim"

# =========
# Functions
# =========

#
#
proc parseServerCommand*(config: Configuration, setServerPort: int): bool =
  var auth = prepareUserDatabase(config.users_db_path, config.admin_username, config.admin_password)

  # ============
  # Routing Maps
  # ============

  router Authentication:
    post "/register":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          },
          "body": {
            "username": "...",
            "password": "...",
            "level": "user"
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username

        let register_username = $payload["body"]["username"]
        let register_password = $payload["body"]["password"]
        let register_role = $payload["body"]["role"]

        let did_succeed = createNewUser(config, auth, register_username, register_password, register_role)
        if not did_succeed:
          fatal("Failed to create new user!")

        auth.logout()
      except:
        resp Http401

    post "/validate":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username

        auth.logout()
      except:
        resp Http401

  router Actions:
    post "/add":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          },
          "body": {
            "name": "...",
            "url": "...",
            "tags": [ "..." ]
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username

        auth.logout()
      except:
        resp Http401

    post "/remove":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          },
          "body": {
            "name": "...",
            "url": "...",
            "tags": [ "..." ]
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username

        auth.logout()
      except:
        resp Http401

    post "/search":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          },
          "body": {
            "name": "...",
            "url": "...",
            "tags": [ "..." ]
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username

        if payload.hasKey("body"):
          let search_by_name = payload["body"].hasKey("name")
          let search_by_url = payload["body"].hasKey("url")
          let search_by_tag = payload["body"].hasKey("tag")


        auth.logout()
      except:
        resp Http401

    post "/twitter-gif":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          },
          "body": {
          }
        }
      ]#
      auth.headers_hook(request.headers)
      let payload = parseJson(request.body)
      let username = $payload["auth"]["username"]
      let password = $payload["auth"]["password"]
      try:
        auth.login(username, password)

        let user = auth.current_user()
        let did_login = user.username == username
        #handleTwitterGif(request)

        auth.logout()
      except:
        resp Http401

  router Interface:
    extend Authentication, ""
    extend Actions, ""

  router Kisuru:
    extend Interface, "/api/v1"

  let server_port =
    if setServerPort == DefaultServerPort: config.port
    else: setServerPort
  var site_settings = newSettings(port = Port(server_port))
  var website = initJester(Kisuru, site_settings)
  website.serve()

