# =======
# Imports
# =======

import unittest

# Standard Library Imports
import os
import times
import strtabs
import sequtils

# Third Party Package Imports

# Package Imports
import kisurupkg/[ certificate ]

# =========
# Constants
# =========
const
  Test_Certificate_Path = parentDir(currentSourcePath()) / "assets" / "fullchain.pem"

# =====
# Tests
# =====


suite "Certificate":

  test "Split Value: Multiple":
    let value = "C=US,O=Let's Encrypt,CN=R3"
    let values = splitValue(value)

    let answer = ["C=US", "O=Let's Encrypt", "CN=R3"]

    check:
      values == answer

  test "Split Value: Single":
    let value = "CN=pewpewthespells.com"
    let values = splitValue(value)

    let answer = ["CN=pewpewthespells.com"]

    check:
      values == answer

  test "Parse Value: Multiple":
    let value = "C=US,O=Let's Encrypt,CN=R3"
    let values = parseValue(value)

    var answer = {"C": "US", "O": "Let's Encrypt", "CN": "R3"}.newStringTable

    let values_keys = toSeq(values.keys())
    let answer_keys = toSeq(answer.keys())

    check:
      values_keys == answer_keys

    for key in values_keys:
      let item = values[key]
      check:
        answer.hasKey(key) == true

      if answer.hasKey(key):
        let answer_value = answer[key]
        check:
          item == answer_value

  test "Parse Value: Single":
    let value = "CN=pewpewthespells.com"
    let values = parseValue(value)

    var answer = {"CN": "pewpewthespells.com"}.newStringTable

    let values_keys = toSeq(values.keys())
    let answer_keys = toSeq(answer.keys())

    check:
      values_keys == answer_keys

    for key in values_keys:
      let item = values[key]
      check:
        answer.hasKey(key) == true

      if answer.hasKey(key):
        let answer_value = answer[key]
        check:
          item == answer_value

  test "Get Issuer":
    let certificate = loadCertificate(Test_Certificate_Path)
    let issuer = certificate.getIssuer()

    let answer = "C=US,O=Let's Encrypt,CN=R3"

    check:
      issuer == answer

  test "Get Subject":
    let certificate = loadCertificate(Test_Certificate_Path)
    let subject = certificate.getSubject()

    let answer = "CN=pewpewthespells.com"

    check:
      subject == answer

  test "Get Expiration Date":
    let certificate = loadCertificate(Test_Certificate_Path)
    let time = certificate.getExpirationTime()
    let date = utc(time)

    let value = initDateTime(02, mMay, 2021, 16, 33, 42, utc())

    check:
      date == value

  test "Get Activation Date":
    let certificate = loadCertificate(Test_Certificate_Path)
    let time = certificate.getActivationTime()
    let date = utc(time)

    let value = initDateTime(01, mFeb, 2021, 16, 33, 42, utc())

    check:
      value == date
