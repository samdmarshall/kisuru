
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

  # File Extensions
  FileExt_Rst* = "rst"
  FileExt_Yaml* = "yaml"
  FileExt_Html* = "html"

  # Application Constants
  Path_Index_Html* = "index.html"
