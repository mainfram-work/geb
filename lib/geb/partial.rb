# frozen_string_literal: true
#
# Represents a page partial. A page partial is a file that contains
# content that is to be inserted in the page at the pace where the partial was
# declared. The class keeps a cache of already loaded partials.
#
# @title Geb - Partial
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @todo Make partial pattern configurable
#
# @see https://github.com/mainfram-work/geb for more information

# include the required libraries
require 'fileutils'

module Geb
  class Partial

    # partial pattern constant
    PARTIAL_PATTERN = /<%= partial: (?<path>.*?) %>/

    class PartialFileNotFound < Geb::Error
      MESSAGE = "Partial file not found".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class PartialFileNotFound < Geb::Error

    class PartialFileReadFailure < Geb::Error
      MESSAGE = "PFailed to read the partial file.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class PartialFileReadFailure < Geb::Error

    # define a class level cache for loaded partial objects
    @@loaded_partials = {}

    # class method to expire the partial cache
    def self.expire_cache
      @@loaded_partials = {}
    end # def self.expire_cache

    # class method to initialise a partial if it is not already loaded, otherwise, return the cached partial
    # @param partial_path [String] the path to the partial file
    # @return [Geb::Partial] the partial object
    def self.load(partial_path)

      # initialise a return partial object
      return_partial = nil

      # check if the partial is already loaded
      if @@loaded_partials.key?(partial_path)

        # return the cached partial
        Geb.log " - using cached partial: #{partial_path}"
        return_partial = @@loaded_partials[partial_path]

      else

        # create a new partial object
        return_partial = Partial.new(partial_path)

        # add the partial to the cache
        @@loaded_partials[partial_path] = return_partial

      end # if else

      # return the partial object
      return return_partial

    end # def self.load

    # class method to process partials in a page
    # @param site_path [String] the path to the site
    # @param page_content [String] the content of the page
    # @return [Array] an array containing the number of partials found and the page content
    # @raise [PartialFileNotFound] if the partial file does not exist
    # @raise [PartialFileReadFailure] if the partial file could not be read
    def self.process_partials(site_path, page_content)

      # initialise a counter to count the number of partials found on the page
      partial_count = 0

      # initialize return page content
      return_page_content = page_content.dup

      # scan the page content for partials
      return_page_content.gsub!(PARTIAL_PATTERN) do |match|

        # match the partial relative and full paths
        partial_file_path =  match.match(PARTIAL_PATTERN)[:path].strip
        partial_file_full_path = File.join(site_path, partial_file_path)

        # load the partial object
        partial = Partial.load(partial_file_full_path)

        # increment the partial count
        partial_count += 1

        # return the partial content
        partial.content

      end # page_content.scan(PARTIAL_PATTERN) do |match|

      # return the array of partial paths
      return partial_count, return_page_content

    end # def self.extract_partial_paths

    # @!attribute [r] path
    # @return [String] the path to the partial file
    attr_reader :path

    # @!attribute [r] content
    # @return [String] the content of the partial file
    attr_reader :content

    # initialise a new partial object
    # @param partial_path [String] the path to the partial file
    # @raise [PartialFileNotFound] if the partial file does not exist
    # @raise [PartialFileReadFailure] if the partial file could not be read
    # @return [Geb::Partial] the partial object
    def initialize(partial_path)

      # set the partial path
      @path = partial_path
      @content = nil

      # check if the partial file exists
      raise PartialFileNotFound.new(partial_path) unless partial_file_exists?()

      Geb.log " - loading partial: #{@path}"

      # read the template file, raise an error if the file could not be read
      begin
        @content = File.read(partial_path)
      rescue => e
        raise PartialFileReadFailure.new(e.message)
      end # begin

    end # def initialize

    # check if the partial file exists
    # @return [Boolean] true if the partial file exists, otherwise false
    def partial_file_exists?
      return File.exist?(@path)
    end # def template_file_exists?

  end # class Partial
end # module Geb
