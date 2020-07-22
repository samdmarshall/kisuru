# =======
# Imports
# =======

# Standard Library Imports
import os
import sequtils

# Third Party Package Imports
#import httpauth
import "../../httpauth/httpauth.nim"
#import httpauth/base
import "../../httpauth/httpauthpkg/base.nim"

# Package Imports


# =========
# Functions
# =========

#
#
proc authenticateUser*(user: string, token: string): bool =
  result = (user == "demi")

#
#
proc createNewUser*(auth: HttpAuth, user: string, pass: string): bool =
  try:
    auth.require(role="admin")
    auth.create_user(user, "user", pass)
    result = true
  except AuthError:
    echo getCurrentExceptionMsg()
    result = false

#
#
proc prepareUserDatabase*(): HttpAuth =
  let backend = newSQLBackend("sqlite://" & absolutePath("assets" / "users.db"))
  result = newHTTPAuth("localhost", backend)
  var users = result.list_users()
  keepIf[User](users, proc(x: User): bool = x.username == "admin")
  if users.len == 0:
    result.initialize_admin_user(password="1234abcd")
