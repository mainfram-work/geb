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

  # copy the specified file and directory paths to the destination directory
  # @param source_path [String] the source directory
  # @param paths [Array] the paths to copy (still full paths, but from source directory)
  # @param destination_path [String] the destination directory
  # @param quiet [Boolean] the flag to suppress output
  # @raise [Geb::Error] if the any of the file operations fail
  def self.copy_paths_to_directory(source_path, paths, destination_path, quiet = false)

    # step through the resolved template paths and copy them to the site path, taking care of files vs directories
    paths.each do |path|

      # get the relative path of the resolved template path and build the destination path
      relative_template_path = path.gsub(source_path, "")
      destination_file_path = File.join(destination_path, relative_template_path)

      # ensure the destination directory exists
      FileUtils.mkdir_p(File.dirname(destination_path))

      # copy the resolved template path to the destination path
      if File.directory?(path)
        Geb.log_start " - copying directory and all sub-directories from #{path} to #{destination_file_path} ... " unless quiet
        FileUtils.cp_r(path, destination_file_path)
      else
        Geb.log_start " - copying file from #{path} to #{destination_file_path} ... " unless quiet
        FileUtils.cp(path, destination_file_path)
      end # if else
      Geb.log "done." unless quiet

    end # each

  rescue Exception => e
    raise Geb::Error.new("Failed to copy paths to directory: #{e.message}")

  end # def self.copy_paths_to_directory


end # module Geb
