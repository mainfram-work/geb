# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Main module definition for the Geb gem
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include external libraries
require "dry/cli"

# include geb commands
require_relative "geb/version"
require_relative "geb/build"
require_relative "geb/release"
require_relative "geb/server"
require_relative "geb/init"
require_relative "geb/auto"
require_relative "geb/upload"
require_relative "geb/remote"

# include geb libraries
require_relative "geb/cli"

module Geb

  VERSION = "0.3.0"

  class Error < StandardError; end
  
end
