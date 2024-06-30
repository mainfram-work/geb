# frozen_string_literal: true
#
# A simple list of Geb utilities for the Geb gem
#
# @title Geb - Utilities
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb

  # define the main error class
  class Error < StandardError

    # initialize the error class
    # @param custom_error [String] the custom error message
    # @param default_message [String] the default error message
    # @return [Geb::Error] the error object
    # @raise [Geb::Error] the error object
    def initialize(custom_error = "", default_message = "")

      # set the error message
      message = custom_error.empty? ? default_message : "#{custom_error} #{default_message}"

      # call the parent class constructor
      super(message)

    end # def initialize

  end # class Error < StandardError

  # initialise a flag for suppressing output
  @@suppress_log_output = false

  # log method for printing messages to the console
  # @param message [String] the message to print
  # @note this method will print a newline character at the end of the message
  # @note this method will print the message to the console if the suppress log output flag is not set
  def self.log(message)
    puts message unless @@suppress_log_output
  end # def self.log

  # log method for printing messages to the console
  # @param message [String] the message to print
  # @note this method will not print a newline character at the end of the message
  # @note this method will print the message to the console if the suppress log output flag is not set
  def self.log_start(message)
    print message unless @@suppress_log_output
  end # def self.log

  # method to suppress log output within a block
  # @return [Object] the return value of the block
  # @yield the block to suppress log output
  def self.no_log

    # store the original value of the suppress log output flag (just in case)
    original_value = @@suppress_log_output

    # set the suppress log output flag
    @@suppress_log_output = true

    # yield the block
    yield

  ensure

    # reset the suppress log output flag
    @@suppress_log_output = original_value

  end # def self.no_log

end # module Geb
