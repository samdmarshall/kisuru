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
  Test_Certificate_Path = parentDir(currentSourcePath()) / "assets" / "example-cert.pem"

# =====
# Tests
# =====


suite "Certificate":

  test "Split Value: Multiple":
    let value = "C=JP,ST=Tokyo,L=Chuo-ku,O=Frank4DD,OU=WebCert Support,CN=Frank4DD Web CA,EMAIL=support@frank4dd.com"
    let values = splitValue(value)

    let answer = ["C=JP", "ST=Tokyo", "L=Chuo-ku", "O=Frank4DD", "OU=WebCert Support", "CN=Frank4DD Web CA", "EMAIL=support@frank4dd.com"]

    check:
      values == answer

  test "Split Value: Single":
    let value = "CN=www.example.com"
    let values = splitValue(value)

    let answer = ["CN=www.example.com"]

    check:
      values == answer

  test "Parse Value: Multiple":
    let value = "C=JP,ST=Tokyo,L=Chuo-ku,O=Frank4DD,OU=WebCert Support,CN=Frank4DD Web CA,EMAIL=support@frank4dd.com"
    let values = parseValue(value)

    var answer = {"C": "JP", "ST": "Tokyo", "L": "Chuo-ku", "O": "Frank4DD", "OU": "WebCert Support", "CN": "Frank4DD Web CA", "EMAIL": "support@frank4dd.com"}.newStringTable

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
    let value = "CN=www.example.com"
    let values = parseValue(value)

    var answer = {"CN": "www.example.com"}.newStringTable

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

    let answer = "C=JP,ST=Tokyo,L=Chuo-ku,O=Frank4DD,OU=WebCert Support,CN=Frank4DD Web CA,EMAIL=support@frank4dd.com"

    check:
      issuer == answer

  test "Get Subject":
    let certificate = loadCertificate(Test_Certificate_Path)
    let subject = certificate.getSubject()

    let answer = "C=JP,ST=Tokyo,O=Frank4DD,CN=www.example.com"

    check:
      subject == answer

  test "Get Expiration Date":
    let certificate = loadCertificate(Test_Certificate_Path)
    let time = certificate.getExpirationTime()
    let date = utc(time)

    let value = initDateTime(21, mAug, 2017, 5, 27, 41, utc())

    check:
      date == value

  test "Get Activation Date":
    let certificate = loadCertificate(Test_Certificate_Path)
    let time = certificate.getActivationTime()
    let date = utc(time)


    let value = initDateTime(22, mAug, 2012, 5, 27, 41, utc())

    check:
      value == date
