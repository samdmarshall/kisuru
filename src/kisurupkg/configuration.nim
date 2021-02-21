# =======
# Imports
# =======

# Standard Library Imports
import os

# Third Party Package Imports
import parsetoml

# Package Imports
import "models.nim"
import "defaults.nim"
#import kisurupkg/[ models, defaults ]

# =========
# Functions
# =========

proc defaultConfiguration*(path: string): Configuration =
  let root = parentDir(path)

  # Settings Default Values
  result.jesterPort = Port(Default_Port_Number)
  result.sourcePath = root / Default_Source_Dir
  result.cachePath  = root / Default_Cache_Dir
  result.staticPath = root / Default_Static_Dir
  result.headerTemplate = Default_Header_Template
  result.footerTemplate = Default_Footer_Template
  result.scanDirForRssFeed = result.sourcePath / Default_Rss_Directory
  result.baseUrl = Default_Rss_BaseUrl

proc initConfiguration*(path: string): Configuration =
  result = defaultConfiguration(path)

  let root = parentDir(path)

  # Check for file at path provided
  if fileExists(path):

    let data = parseFile(path)

    if data.hasKey(Conf_Key_Section_Jester):
      let jester_settings = data.getOrDefault(Conf_Key_Section_Jester)

      if jester_settings.hasKey(Conf_Key_Jester_Port):
        let jester_port = jester_settings.getOrDefault(Conf_Key_Jester_Port)
        result.jesterPort = Port(jester_port.getInt(Default_Port_Number))

    if data.hasKey(Conf_Key_Section_Content):
      let content_settings = data.getOrDefault(Conf_Key_Section_Content)

      if content_settings.hasKey(Conf_Key_Content_Source):
        let source_path = content_settings.getOrDefault(Conf_Key_Content_Source)
        result.sourcePath = root / source_path.getStr(Default_Source_Dir)

      if content_settings.hasKey(Conf_Key_Content_Cache):
        let cache_path = content_settings.getOrDefault(Conf_Key_Content_Cache)
        result.cachePath = root / cache_path.getStr(Default_Cache_Dir)

      if content_settings.hasKey(Conf_Key_Content_Static):
        let static_path = content_settings.getOrDefault(Conf_Key_Content_Static)
        result.staticPath = root / static_path.getStr(Default_Static_Dir)

    if data.hasKey(Conf_Key_Section_Template):
      let template_settings = data.getOrDefault(Conf_Key_Section_Template)

      if template_settings.hasKey(Conf_Key_Template_Header):
        let header_template = template_settings.getOrDefault(Conf_Key_Template_Header)
        result.headerTemplate = header_template.getStr(Default_Header_Template)

      if template_settings.hasKey(Conf_Key_Template_Footer):
        let footer_template = template_settings.getOrDefault(Conf_Key_Template_Footer)
        result.footerTemplate = footer_template.getStr(Default_Footer_Template)

    if data.hasKey(Conf_Key_Section_Render):
      let render_settings = data.getOrDefault(Conf_Key_Section_Render)

    if data.hasKey(Conf_Key_Section_Rss):
      let rss_settings = data.getOrDefault(Conf_Key_Section_Rss)

      if rss_settings.hasKey(Conf_Key_Rss_Directory):
        let rss_scan_directory = rss_settings.getOrDefault(Conf_Key_Rss_Directory)
        result.scanDirForRssFeed = result.sourcePath / rss_scan_directory.getStr(Default_Rss_Directory)

      if rss_settings.hasKey(Conf_Key_Rss_BaseUrl):
        let rss_base_url = rss_settings.getOrDefault(Conf_Key_Rss_BaseUrl)
        result.baseUrl = rss_base_url.getStr(Default_Rss_BaseUrl)
