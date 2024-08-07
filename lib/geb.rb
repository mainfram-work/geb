# frozen_string_literal: true
#
# Main module definition for the Geb gem, it includes all the functionality
# and modules for the Geb gem.
#
# @title Geb
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# Define the main module, version and main error class
module Geb

  # define the version of the gem
  VERSION = "0.1.13"

end # module Geb

# include external libraries
require "dry/cli"

# include geb libraries
require_relative "geb/defaults"
require_relative "geb/utilities"
require_relative "geb/config"
require_relative "geb/git"
require_relative "geb/site"
require_relative "geb/page"
require_relative "geb/template"
require_relative "geb/partial"
require_relative "geb/server"

# make sure geb/cli is loaded last
require_relative "geb/cli"
