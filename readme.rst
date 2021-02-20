
===================================
pewpewthespells website application
===================================

this is an attempt to get rid of all the legacy cruft and page generation that was used in the past to generate html content for my website (pewpewthespells.com). instead of relying on static page generation via a document converter, the app will do on-the-fly page rendering using a single document format.

configuration
=============

the application is configured by a toml (``.toml``) file that is passed directly to the application on the command line. this will have the following format:

*note: if keys are not supplied, the listed default value will be used*

.. code-block:: toml

  [jester]
  port = 5000     # Defaults to "5000"

  [content]
  source = "public/"    # Defaults to "./public/"
  cache = "cache/"      # Defaults to "./cache/"
  static = "static/"    # Defaults to "./static/"

  [template]
  header = "header.template"     # Defaults to "./header.template"
  footer = "footer.template"     # Defaults to "./footer.template"

  [render]



configuration - jester
----------------------

this section contains settings related to the configuration of the jester web framework.

* ``port``: this is the port number that jester will listen on the localhost. while you could set it to be ``80``, running this directly on the open internet is not advised, you should setup a forwarding proxy using ``nginx`` or another web-server to forward the requests.

configuration - content
-----------------------

this section contains settings related to where to find the website content.

* ``source``: this is a directory which will be specified as the default search path for website pages. (see the section on "page format" for more information about what a "page" is)
* ``cache``: this is a directory that will contain cached website content. this is to ensure that the application isn't having to parse and convert the content file from rst into html on each page request. if a page doesn't exist in the cache at time of the request, then it will be generated and saved there.

configuration - template
------------------------

this section contains settings related to where to find the templates for rendering the html for the website content.

* ``header``: this is the template file that will contain the contents of the ``<head>...</head>`` tag.
* ``footer``: this is the template file that will contain the contents of the ``<footer>...</footer>`` tag.

page format
===========

each "page" on the website will have two corresponding source files, the content file and a metadata file.

* content file:
  the contents of the page will be housed in a restructured text file (``.rst``).

* metadata file:
  the metadata of the page (published status, title, publication date, summary description, etc) will be housed in a yaml file (``.rst.yaml``).

the html will be generated from the content file using Nim's ``docutils.rst`` package, which will be the ``<body>...</body>`` of the page, the header and footer will be generated separately based on metadata and templates provided in the configuration.


requesting a page
=================

this is an outline of the expected steps in requesting to view a page from the website application.

1. browser makes a request of app: pewpewthespells.com/foo/bar.html
2. application recieves request, parses it as
    query: /foo/bar
    extension: html
3. look up file
  1. check cache -> <cache>/foo/bar.html
    1. exists in cache, check if outdated file against source (last modified dates)
    2. render page from cache, if cache is newer
    3. render page from source, if source is newer
      1. save new render of page to cache
  2. check source -> <source>/foo/bar.*
    1. find page files for query (``/foo/bar.rst``, ``/foo/bar.rst.yaml``)
    2. parse content and metadata files
      1. decide if they should be rendered
      2. render page
      3. save page to cache
    3. display newly cached content
  3. file is part of static content


page metadata definition
========================

these are the defined keys for page metadata:

.. code-block:: yaml
  root: [ yes | no ]
  published: [ yes | no ]
  date: MMMM DD, YYYY
  title: <#title of page#>
  summary: <#description of page#>
  disablefooter: [ yes | no ]
  disableheader: [ yes | no ]

