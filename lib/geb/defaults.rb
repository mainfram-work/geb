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

module Geb
  module Defaults

    # default the template archive filename
    TEMPLATE_ARCHIVE_FILENAME = 'geb-template.tar.gz'

    # list of bundled templates (first one is the default template)
    AVAILABLE_TEMPLATES       = ['bootstrap_jquery', 'basic']

    # site config file name
    SITE_CONFIG_FILENAME      = 'geb.config.yml'

    # bundled template directory
    BUNDLED_TEMPLATES_DIR     = File.join(__dir__, 'samples')

    # default template directory
    DEFAULT_TEMPLATE_DIR      = File.join(BUNDLED_TEMPLATES_DIR, AVAILABLE_TEMPLATES.first)

    # default template
    DEFAULT_TEMPLATE         = AVAILABLE_TEMPLATES.first

    # local and release output directories (relative to the site root)
    LOCAL_OUTPUT_DIR          = 'output/local'
    RELEASE_OUTPUT_DIR        = 'output/release'


  end # module Defaults
end # module Geb
