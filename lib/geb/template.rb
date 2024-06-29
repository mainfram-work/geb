# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Represents a page template. A page template is a page file that contains
#  template definitions and insert sections. The class keeps a cache of
#  already loaded page templates.
#
#  Licence MIT
# -----------------------------------------------------------------------------

require 'fileutils'

module Geb
  class Template

    TEMPLATE_PATTERN  = /<% template: (.*?) %>/
    SECTION_PATTERN   = /<% start: (.*?) %>(.*?)<% end: \1 %>/m
    INSERT_PATTERN    = /<%= insert: (.*?) %>/

    class TemplateFileNotFound < Geb::Error
      MESSAGE = "Template file not found".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class TemplateFileNotFound < Geb::Error

    class TemplateFileReadFailure < Geb::Error
      MESSAGE = "Failed to read the template file.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class TemplateFileReadFailure < Geb::Error

    # define a class level cache for loaded template objects
    @@loaded_templates = {}

    # class method to expire the template cache
    def self.expire_cache
      @@loaded_templates = {}
    end # def self.expire_cache

    # class method to initialise a template if it is not already loaded, otherwise, return the cached template
    # @param template_path [String] the path to the template file
    # @return [Geb::Template] the template object
    def self.load(template_path)

      # initialise a return template object
      return_template = nil

      # check if the template is already loaded
      if @@loaded_templates.key?(template_path)

        # return the cached template
        Geb.log " - using cached template: #{template_path}"
        return_template = @@loaded_templates[template_path]

      else

        # create a new template object
        return_template = Template.new(template_path)

        # add the template to the cache
        @@loaded_templates[template_path] = return_template

      end # if else

      # return the new template object
      return return_template

    end # def self.load

    # extract the template path from the page content
    # @param page_content [String] the page content
    # @return [String] the template path, or nil if no template path is found
    # @note the function looks for tags like this <% template: shared/templates/_site.html %> in the page content
    def self.extract_template_path(page_content)

      # match the template pattern and return the template path
      match = page_content.match(TEMPLATE_PATTERN)

      # return the template path or nil if no match
      return match ? match[1].strip : nil

    end # def self.extract_template_path

    # extract the sections for the template from the page content
    # @param page_content [String] the page content
    # @return [Hash] the sections for the template, key is the section name, value is the section content
    # @note the function looks for tags like this <% start: header %> ... <% end: header %> in the page content and returns whats in between
    def self.extract_sections_for_template(page_content)

      # initialise the sections for the template hash
      sections_for_template = {}

      # scan the page content for sections and add them to the hash
      page_content.scan(SECTION_PATTERN).each do |section|
        sections_for_template[section[0].strip] = section[1].strip
      end # scan

      # return the sections for the template
      return sections_for_template

    end # def self.extract_sections_for_template

    # setup attribute accessors
    attr_reader :path, :content

    # Template class constructor
    # @param template_path [String] the path to the template file
    # @return [Geb::Template] the template object
    def initialize(template_path)

      # set the specified template path and initialise the content
      @path = template_path
      @content = nil

      # check if the template file exists
      raise TemplateFileNotFound.new(template_path) unless template_file_exists?()

      Geb.log " - loading template: #{@path}"

      # read the template file, raise an error if the file could not be read
      begin
        @content = File.read(template_path)
      rescue => e
        raise TemplateFileReadFailure.new(e.message)
      end # begin

    end # def initialize

    # parse the page content sections and replace the sections in the template with the page section content
    # @param page_content_sections [Hash] the page content sections, key is the section name, value is the section content
    # @return [String] the parsed template content
    # @note the function looks for tags like this <%= insert: header %> in the template content
    def parse(page_content_sections)

      # create a duplicate of the template content
      return_content = @content.dup

      # step through the page content sections and replace the insert sections in the template with the page content
      return_content.gsub!(INSERT_PATTERN) do |match|
        section_name = match.match(INSERT_PATTERN)[1].strip
        page_content_sections[section_name] || match
      end # return_content.gsub!

      # return the content
      return return_content

    end # def parse

    private

    # check if the template file exists
    # @return [Boolean] true if the template file exists, otherwise false
    def template_file_exists?
      return File.exist?(@path)
    end # def template_file_exists?

  end # class Template
end # module Geb
