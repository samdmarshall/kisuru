
# =======
# Imports
# =======

# Standard Library Imports
import json
import logging
import strtabs
import strutils
import strformat
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
import "../database.nim"
#import kisurupkg/command/[ add, remove, search ]
import "../command/add.nim"
import "../command/remove.nim"
import "../command/search.nim"

# =========
# Functions
# =========

#
#
template handleRequest(request: Request, auth: HTTPAuth, payload: JsonNode, body: untyped): untyped =
  auth.headers_hook(request.headers)
  if not payload.hasKey("auth"):
    error("Invalid JSON: Missing key 'auth'")
  let username = $payload["auth"].getOrDefault("username")
  let password = $payload["auth"].getOrDefault("password")
  try:
    info("Logging in with credentials for: $# ..." % [username])
    auth.login(username, password)

    let user = auth.current_user()
    let did_login = user.username == username

    if not did_login:
      warn("Login failed!")

    block:
      body

  except:
    error("Login Failed using credentials for: $#" % [username])
    resp Http401
  finally:
    info("Logging out of account: $#" % [username])
    auth.logout()

#
#
proc parseServerCommand*(config: Configuration, setServerPort: int): bool =
  var auth = prepareUserDatabase(config.users_db_path, config.admin_username, config.admin_password)
  let db = initDatabase(config)

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
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        if not payload.hasKey("body"):
          error("Invalid JSON: Missing key 'body'")
        let register_username = $payload["body"].getOrDefault("username")
        let register_password = $payload["body"].getOrDefault("password")
        let register_role = $payload["body"].getOrDefault("role")
        let did_succeed = createNewUser(config, auth, register_username, register_password, register_role)
        if not did_succeed:
          fatal("Failed to create new user!")

    post "/validate":
      #[
        {
          "auth": {
            "username": "...",
            "password": "..."
          }
        }
      ]#
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        discard

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
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        if not payload.hasKey("body"):
          error("Invalid JSON: Missing key 'body'")

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
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        if not payload.hasKey("body"):
          error("Invalid JSON: Missing key 'body'")

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
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        if not payload.hasKey("body"):
          error("Invalid JSON: Missing key 'body'")
        var attributes = newStringTable()
        if payload["body"].hasKey("name"):
          attributes["name"] = $payload["body"].getOrDefault("name")
        if payload["body"].hasKey("url"):
          attributes["url"] = $payload["body"].getOrDefault("url")
        if payload["body"].hasKey("tag"):
          attributes["tag"] = $payload["body"].getOrDefault("tag")
        let results = db.findBookmarksByAttributes(attributes)

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
      let payload = parseJson(request.body)
      handleRequest(request, auth, payload):
        if not payload.hasKey("body"):
          error("Invalid JSON: Missing key 'body'")
        #handleTwitterGif(request)


  router Interface:
    extend Authentication, ""
    extend Actions, ""

  router Kisuru:
    extend Interface, "/api/v{config.db_version}"

  let server_port =
    if setServerPort == DefaultServerPort: config.port
    else: setServerPort
  var site_settings = newSettings(port = Port(server_port))
  var website = initJester(Kisuru, site_settings)
  website.serve()

