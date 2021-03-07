# =======
# Imports
# =======

# Standard Library Imports
import strformat

# Third Party Package Imports
import jester
import taskqueue
import commandeer

# Package Imports
import kisurupkg/[ models, defaults, configuration, webpage, templates, rss ]
import kisurupkg/page/[ filepath ]

# =====
# Types
# =====

type
  CommandLineInput* = object
    sitemapFile: string

# ===========
# Entry Point
# ===========

proc main() =

  commandline:
    argument SitemapFile, string
    exitoption Flag_Long_Help, Flag_Short_Help, fmt"usage: {NimblePkgName} [-{Flag_Short_Help}|--{Flag_Long_Help}] [-{Flag_Short_Version}|--{Flag_Long_Version}] <website.toml>"
    exitoption Flag_Long_Version, Flag_Short_Version, fmt"{NimblePkgName} v{NimblePkgVersion}"

  let conf = initConfiguration(SitemapFile)

  let rss = conf.generateRssFeed()
  echo $rss

  router legacy:
    discard

  router pewpewthespells:
    extend legacy, ""

    get "/@path?.?@ext?":
      var page = conf.resolvePath(request)
      case page.kind
      of wpDynamic:
        let is_cached = page.isCached()
        let is_outdated = page.isCacheOutdated()

        let should_update_cache = (not is_cached) or (is_cached and is_outdated)
        if should_update_cache:
          let page_contents = page.renderTemplate()
          let successful_cache = page.updateCache(page_contents)
          resp page_contents
        else:
          for filepath in page.cachePath.filePaths():
            sendFile(filepath)
      of wpStatic:
        for filepath in page.staticPath.filePaths():
          sendFile(filepath)
      else:
        resp(Http404)
      # var page = conf.resolvePage(request)
      # case page.kind
      # of pkSource:
      #   let is_cached = page.isCached(conf)
      #   let is_outdated = page.isCacheOutdated(conf)

      #   let should_update_cache = (not is_cached) or (is_cached and is_outdated)
      #   if should_update_cache:
      #     let page_contents = conf.renderTemplate(page)
      #     let successful_cache = page.updateCache(page_contents)
      #     resp page_contents
      #   else:
      #     sendFile(page.cachePath)

      # of pkStatic:
      #   sendFile(page.staticPath)
      # else:
      #   halt()

  var config = newSettings(port = conf.jesterPort)
  var website = initJester(pewpewthespells, settings=config)
  website.serve()

when isMainModule:
  main()
