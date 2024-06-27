# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  A simple list of defaults for the Geb gem
#
#  Licence MIT
# -----------------------------------------------------------------------------

require 'fileutils'

module Geb
  module Defaults

    # default values for site templates
    TEMPLATE_ARCHIVE_FILENAME = 'geb-template.tar.gz'             # default the template archive filename
    AVAILABLE_TEMPLATES       =                                   # list of bundled templates (first one is the default template)
      ['bootstrap_jquery', 'basic']
    SITE_CONFIG_FILENAME      = 'geb.config.yml'                  # site config file name
    BUNDLED_TEMPLATES_DIR     =                                   # bundled template directory
      File.join(__dir__, 'samples')
    DEFAULT_TEMPLATE_DIR      =                                   # default template directory
      File.join(BUNDLED_TEMPLATES_DIR, AVAILABLE_TEMPLATES.first)
    DEFAULT_TEMPLATE          =                                   # default template
      AVAILABLE_TEMPLATES.first

    # default values for site configuration (all paths are relative to the site root)
    LOCAL_OUTPUT_DIR          = 'output/local'                    # local output directory
    RELEASE_OUTPUT_DIR        = 'output/release'                  # release output directory
    ASSETS_DIR                = 'assets'                          # location for assets (images, js and css)

    # default values for site pages
    PAGE_EXTENSIONS           =
      ['.md', '.markdown', '.html', '.htm', '.txt']               # list of file extention to treat as pages
    TEMPLATE_AND_PARTIAL_IDENTIFIER  = /^_/                       # filename pattern for templates or partials

  end # module Defaults
end # module Geb
