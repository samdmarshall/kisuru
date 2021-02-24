
====================
anatomy of a request
====================

* client asks for the content located at a particular path from the server:
  "/index.html"
* the server then has to look up this content:
  * check in the cached files "./content/cache/index.html"
    * found file: "./content/cache/index.html"
    * lookup the path to the corresponding source version of the file
    * compare the last modified dates of the current cached file to the most recent date between the last modified dates of the content file (.rst) and the metadata file (.yaml) to determine if a new version needs to be made
      * remove old cache file if it is outdated
  * check in the source files "./content/public/index.*"
    * found files: "./content/public/index.rst" and "./content/public/index.yaml"
    * generate the "html" version and save it to the cache
    * return contents of newly cached file
  * check in the static files "./content/static/index.html"
    * return contents of static file
  * unable to find any corresponding content for path
    * return appropriate error message
