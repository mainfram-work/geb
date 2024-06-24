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

  # define the main error class
  class Error < StandardError

    # initialize the error class
    def initialize(custom_error = "", default_message = "")
      message = custom_error.empty? ? default_message : "#{custom_error} #{default_message}"
      super(message)
    end # def initialize

  end # class Error < StandardError

  # log method for printing messages to the console
  def self.log (message)
    puts message
  end # def self.log

  # log method for printing messages to the console
  def self.log_start (message)
    print message
  end # def self.log

end # module Geb

# include external libraries
require "dry/cli"

# include geb libraries
require_relative "geb/git"
require_relative "geb/site"
require_relative "geb/cli" # make sure this is loaded last
