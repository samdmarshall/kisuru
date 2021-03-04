
# =======
# Imports
# =======

# Standard Library Imports
import os
import times
import strtabs
import strutils
import parseutils

# Third Party Package Imports
import gnutls
import x509

# Package Imports


# =====
# Types
# =====

type
  GnuTLSError* = object of CatchableError

  CertificateX509* = object
    crt: gnutls_x509_crt_t

# Templates

template checkResult*(code: cint): untyped =
  if code != 0:
    raise newException(GnuTLSError, $gnutls_strerror(code))

# =========
# Functions
# =========

proc splitValue*(value: string): seq[string] =
  let string_length = len(value)
  var index = 0
  while index < string_length:
    var token: string
    let split_index = parseUntil(value, token, {','}, index)
    result.add token
    index += split_index + 1

proc parseValue*(value: string): StringTableRef =
  result = newStringTable()
  for item in splitValue(value):
    let string_length = len(item)
    var index = 0
    while index < string_length:
      var key: string
      let key_length = parseUntil(item, key, {'='}, index)
      index += key_length + 1
      var value: string
      let value_length = parseUntil(item, value, {'='}, index)
      result[key] = value
      index += value_length


proc validateChecks*(args: varargs[cint]): bool =
  var has_failed = false
  for code in args:
    try:
      checkResult code
    except:
      has_failed = true
    if has_failed:
      return false
  return true

proc `$`(data: gnutls_x509_dn_t): string =
  var data_string: gnutls_datum_t
  let get_str_result = gnutls_x509_dn_get_str(data, addr data_string)
  checkResult get_str_result
  result = $cstring(data_string.data)

proc getActivationTime*(x509: CertificateX509): Time =
  let activation_as_epoch = gnutls_x509_crt_get_activation_time(x509.crt)
  result = fromUnix(activation_as_epoch)

proc getExpirationTime*(x509: CertificateX509): Time =
  let expiration_as_epoch = gnutls_x509_crt_get_expiration_time(x509.crt)
  result = fromUnix(expiration_as_epoch)

proc getSubject*(x509: CertificateX509): string =
  var subject: gnutls_x509_dn_t
  let subject_result = gnutls_x509_crt_get_subject(x509.crt, addr subject)
  checkResult subject_result
  result = $subject

proc getIssuer*(x509: CertificateX509): string =
  var issuer: gnutls_x509_dn_t
  let issuer_result = gnutls_x509_crt_get_issuer(x509.crt, addr issuer)
  checkResult issuer_result
  result = $issuer

proc loadCertificate*(path: string): CertificateX509 =
  if fileExists(path):
    var data: gnutls_datum_t
    let load_file_result = gnutls_load_file(path, addr data)
    checkResult load_file_result

    var certificate: gnutls_x509_crt_t
    let crt_init_result = gnutls_x509_crt_init(addr certificate)
    checkResult crt_init_result

    let crt_import_result = gnutls_x509_crt_import(certificate, addr data, GNUTLS_X509_FMT_PEM)
    checkResult crt_import_result

    if validateChecks(load_file_result, crt_init_result, crt_import_result):
      result.crt = certificate


