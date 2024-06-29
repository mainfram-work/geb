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

  # initialise a flag for suppressing output
  @@suppress_log_output = false

  # log method for printing messages to the console
  def self.log(message)
    puts message unless @@suppress_log_output
  end # def self.log

  # log method for printing messages to the console
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

  def self.dump_object_info(object)
    class_name = object.class.name
    instance_variables = object.instance_variables
    methods = object.methods - Object.methods

    puts "Class: #{class_name}"
    puts "Instance Variables:"
    instance_variables.each do |var|
      value = object.instance_variable_get(var)
      puts "  #{var}: #{value.inspect}"
    end

    puts "Methods:"
    methods.sort.each do |method|
      puts "  #{method}"
    end
  end

end # module Geb
