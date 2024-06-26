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

# Define the main module, version and main error class
module Geb

  # define the version of the gem
  VERSION = "0.3.7"

end # module Geb

# include external libraries
require "dry/cli"

# include geb libraries
require_relative "geb/defaults"
require_relative "geb/utilities"
require_relative "geb/git"
require_relative "geb/site"
require_relative "geb/cli" # make sure this is loaded last
