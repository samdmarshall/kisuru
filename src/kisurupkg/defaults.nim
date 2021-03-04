
# =======
# Imports
# =======

# Standard Library Imports
import os

# =========
# Constants
# =========

const
  # Defines from Nimble
  NimblePkgName* {.strdefine.} = ""
  NimblePkgVersion* {.strdefine.} = ""

  # Command Line Flags
  Flag_Long_Help* = "help"
  Flag_Short_Help* = "h"

  Flag_Long_Version* = "version"
  Flag_Short_Version* = "v"

  # Default Values
  Default_Port_Number* = 5000
  Default_Source_Dir* = "public"
  Default_Cache_Dir* = "cache"
  Default_Static_Dir* = "static"
  Default_Header_Template* = "header.template"
  Default_Footer_Template* = "footer.template"
  Default_Rss_Directory* = "blog"
  Default_Rss_BaseUrl* = "https://example.com"

  # Configuration Key Strings
  Conf_Key_Section_Jester* = "jester"
  Conf_Key_Jester_Port* = "port"

  Conf_Key_Section_Content* = "content"
  Conf_Key_Content_Source* = "source"
  Conf_Key_Content_Cache* = "cache"
  Conf_Key_Content_Static* = "static"

  Conf_Key_Section_Template* = "template"
  Conf_Key_Template_Header* = "header"
  Conf_Key_Template_Footer* = "footer"

  Conf_Key_Section_Render* = "render"

  Conf_Key_Section_Rss* = "rss"
  Conf_Key_Rss_Directory* = "directory"
  Conf_Key_Rss_BaseUrl* = "baseurl"

  # File Extensions
  FileExt_Rst* = "rst"
  FileExt_Yaml* = "yaml"
  FileExt_Html* = "html"

  # Application Constants
  IndexPageName* = "index"
  Path_Index_Html* = IndexPageName & ExtSep & FileExt_Html

  # Date & Time Formatters
  Default_Metadata_PostDate_Formatter* = "MMMM d, YYYY"
  Default_PubDate_Date_Formatter* = "ddd, dd MMM YYYY"
  Default_PubDate_Time_Formatter* = "HH:mm:ss z"
  Default_PubDate_DateTime_Formatter* = Default_PubDate_Date_Formatter & " " & Default_PubDate_Time_Formatter
