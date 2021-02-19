# =======
# Imports
# =======

# Standard Library Imports
import os
import logging
import sequtils

# Third Party Package Imports
#import httpauth
import "../../httpauth/httpauth.nim"
#import httpauth/base
import "../../httpauth/httpauthpkg/base.nim"

# Package Imports
#import kisurupkg/[ config, defaults ]
import "defaults.nim"
import "config.nim"

# =========
# Functions
# =========

#
#
proc authenticateUser*(user: string, token: string): bool =
  result = (user == "demi")

#
#
proc createNewUser*(config: Configuration, auth: HttpAuth, user: string, pass: string, role: string): bool =
  try:
    auth.require(role=config.admin_username)
    auth.create_user(user, pass, role, "", "")
    result = true
  except AuthError:
    fatal(getCurrentExceptionMsg())
    result = false

#
#
proc prepareUserDatabase*(path: string = DefaultUsersDbPath, admin_username: string, admin_password: string): HTTPAuth =
  let backend = newSQLBackend("sqlite://" & path)
  result = newHTTPAuth("localhost", backend)
  var users = result.list_users()
  keepIf[User](users, proc(x: User): bool = x.username == admin_username)
  if users.len == 0:
    result.initialize_admin_user(password=admin_password)
