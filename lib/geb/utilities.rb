# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  A simple list of Geb utilities for the Geb gem
#
#  Licence MIT
# -----------------------------------------------------------------------------

module Geb

  # define the main error class
  class Error < StandardError

    # initialize the error class
    def initialize(custom_error = "", default_message = "")
      message = custom_error.empty? ? default_message : "#{custom_error} #{default_message}"
      super(message)
    end # def initialize

  end # class Error < StandardError

  # log method for printing messages to the console
  def self.log(message)
    puts message
  end # def self.log

  # log method for printing messages to the console
  def self.log_start(message)
    print message
  end # def self.log

end # module Geb
