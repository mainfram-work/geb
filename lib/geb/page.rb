# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Represents a site object, handles creation of new sites and site templates
#  Templates can be one of the following:
#   - name of the site template that comes bundled with geb
#   - a local directory that is a valid site template
#   - a URL to a gab site template packaged as a zip file
#
#  Licence MIT
# -----------------------------------------------------------------------------

require 'fileutils'

module Geb
  class Page

    INSERT_PATTERN    = /<%= insert: (.*?) %>/

    class PageFileNotFound < Geb::Error
      MESSAGE = "Page file not found".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class PageFileNotFound < Geb::Error

    class PageFileReadFailure < Geb::Error
      MESSAGE = "Failed to read the page file.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class PageFileReadFailure < Geb::Error

    class PageMissingTemplateDefition < Geb::Error
      MESSAGE = "Page is missing template defitions but has insert sections defined".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class PageMissingTemplateDefition < Geb::Error

    class FailedToOutputPage < Geb::Error
      MESSAGE = "Failed to create output page".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class FailedToOutputPage < Geb::Error

    # define attr_reader for the site and path
    attr_reader :site, :path, :content, :parsed_content

    def initialize(site, path)

      # set the site and path
      @site = site
      @path = path

      # check if the page file exists
      raise PageFileNotFound.new(@path) unless page_file_exists?

      Geb.log ""
      Geb.log " - loading page: #{page_name}"

      # read the page file, raise an error if the file could not be read
      begin
        @content = File.read(@path)
      rescue => e
        raise PageFileReadFailure.new(e.message)
      end # begin

      # parse the page content
      parse()

    end # def initialize

    # parse the page content
    def parse

      # initalise the new page content
      @parsed_content = @content.dup

      # parse the content for templates and partials
      @parsed_content = parse_for_templates(@parsed_content)
      @parsed_content = parse_for_partials(@parsed_content)

    end # def parse

    # parse the content for templates. This method will keep looking for templates until all templates are found as
    # templates can be based on templates.
    # @param content [String] the content to parse for templates. Default is the parsed page content.
    # @return [String] the parsed content, with no templates to parse.
    # @raise [PageMissingTemplateDefition] if a template sections are found but the template declaration is not.
    def parse_for_templates(content = @parsed_content)

      # initialise a flag to keep looking for templates
      keep_looking_for_template = true

      # keep looking for template until we find them all
      while keep_looking_for_template

        # attempt to extract the template path and sections
        template_path     = Geb::Template.extract_template_path(content)
        template_sections = Geb::Template.extract_sections_for_template(content)

        # raise an error if template sections are defined but the template is not
        raise PageMissingTemplateDefition.new(page_name) if template_sections.any? && template_path.nil?

        # check if we found a template
        if template_path.nil?

          # we did not find a template, so we are done
          keep_looking_for_template = false

        else

          # create a new template object
          template = Geb::Template.load(File.join(@site.site_path, template_path))

          # parse the template content and replace the insert sections
          content = template.parse(template_sections)

        end # unless template_path.nil?

      end # while keep_looking_for_template

      # return the parsed content with templates handled
      return content

    end # def parse_for_templates

    # parse the content for partials. This method will keep looking for partials until all partials are found as
    # partials can be embeded in other partials.
    # @param content [String] the content to parse for partials. Default is the parsed page content.
    # @return [String] the parsed content, with no partials to parse.
    def parse_for_partials(content = @parsed_content)

      # initialise a flag to keep looking for partials
      keep_looking_for_partials = true

      # keep looking for partials until we find them all (partials can be embeded in other partials)
      while keep_looking_for_partials

        # attempt to extract the partial paths
        found_partials, content = Geb::Partial.process_partials(@site.site_path, content)

        # check if we found any partials, if not we are done
        keep_looking_for_partials = (found_partials != 0)

      end # while keep_looking_for_partials

      # return the parsed content with partials handled
      return content

    end # def parse_for_partials

    # build the page, save it to the output folder
    def build(output_path)

      # build the page
      Geb.log " - building page: #{page_name}"

      # strip whitespace (spaces and newlines) at the beginning and at the end of the file
      @parsed_content = @parsed_content.strip

      # build the output filename
      output_filename = @path.gsub(@site.site_path, output_path)

      # attempt to create the output directory and file
      begin

        # make sure the output directory for the file exists
        FileUtils.mkdir_p(File.dirname(output_filename))

        # write the content to the output file
        File.write(output_filename, @parsed_content)

      rescue => e
        raise FailedToOutputPage.new(e.message)
      end # begin rescue

    end # def build

    private

    # get the page name by removing the site folder from the path
    # @return [String]
    def page_name
      return @path.gsub(@site.site_path, '')
    end # def page_name

    # check if the page file exists, returns true if the file exists, false otherwise
    # @return [Boolean]
    def page_file_exists?
      return File.exist?(@path)
    end # def page_file_exists?

  end # class Page
end # module Geb
