# frozen_string_literal: true
#
# A simple list of defaults for the Geb gem
#
# @title Geb - Defaults
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# include the required libraries
require 'fileutils'

module Geb
  module Defaults

    # default values for site templates
    TEMPLATE_ARCHIVE_FILENAME = 'geb-template.tar.gz'             # default the template archive filename
    AVAILABLE_TEMPLATES       =                                   # list of bundled templates (first one is the default template)
      ['basic', 'bootstrap_jquery']
    SITE_CONFIG_FILENAME      = 'geb.config.yml'                  # site config file name
    HTTP_TEMPLATE_CONTENT_TYPES =                                 # acceptable remote template content types
      ['application/x-gzip', 'application/gzip', 'application/octet-stream']
    BUNDLED_TEMPLATES_DIR     =                                   # bundled template directory
      File.join(__dir__, 'samples')
    DEFAULT_TEMPLATE_DIR      =                                   # default template directory
      File.join(BUNDLED_TEMPLATES_DIR, AVAILABLE_TEMPLATES.first)
    DEFAULT_TEMPLATE          =                                   # default template
      AVAILABLE_TEMPLATES.first

    # default values for site configuration (all paths are relative to the site root)
    OUTPUT_DIR                = 'output'                          # output directory  (relative to site root)
    LOCAL_OUTPUT_DIR          = 'local'                           # local output directory (relative to output directory)
    RELEASE_OUTPUT_DIR        = 'release'                         # release output directory (relative to output directory)
    ASSETS_DIR                = 'assets'                          # location for assets (images, js and css)

    # default values for site pages
    PAGE_EXTENSIONS           =                                   # list of file extension to treat as pages
      ['.md', '.markdown', '.html', '.htm', '.txt', '.js', '.css', '.webmanifest']
    TEMPLATE_AND_PARTIAL_IDENTIFIER  = /^_/                       # filename pattern for templates or partials

  end # module Defaults
end # module Geb
