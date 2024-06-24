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

# include required libraries
require 'uri'
require 'net/http'
require 'tmpdir'
require 'open3'
require 'shellwords'

module Geb

  class Site

    # define the template archive filename
    TEMPLATE_ARCHIVE_FILENAME = 'geb-template.tar.gz'

    # list of bundled templates (first one is the default template)
    AVAILABLE_TEMPLATES = ['bootstrap_jquery', 'basic']

    class DirectoryExistsError < Geb::Error
      MESSAGE = "Site folder already exists, please choose a different name or location.\nIf you want to use the existing site folder, use the --force option.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class DirectoryExistsError < Geb::Error

    class InvalidTemplate < Geb::Error
      MESSAGE = "Invalid template site. Make sure the specified path is a directory and contains a valid gab.config.yml file.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class InvalidTemplate < Geb::Error

    class InvalidTemplateURL < Geb::Error
      MESSAGE = "Invalid template URL specified. Ensure the template URL is properly accessible and packaged Gab site using gab release --with_template".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class InvalidTemplateURL < Geb::Error

    class UnvalidatedSiteAndTemplate < Geb::Error
      MESSAGE = "Proposed site and template have not been validated. This is an internal error".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class UnvalidatedSiteAndTemplate < Geb::Error

    # site constructor
    def initialize

      @validated = false
      @site_path = nil
      @template_path = nil

    end # def initialize

    # validate the site path and template path
    def validate(site_path, template_path = nil, skip_template = false, force = false)

      Geb.log_start "Validating site path #{site_path} ... "

      # raise error if site folder already exists and force option is not set
      raise DirectoryExistsError.new if File.directory?(site_path) && !force
      @site_path = site_path

      Geb.log('done.')

      # check if we are skipping the template
      unless skip_template

        # if the template path is nil, use the first bundled template name
        template_path = template_path.nil? ? File.join(__dir__, 'samples', AVAILABLE_TEMPLATES.first) : template_path

        # initialize the template directory path.
        template_dir = ""

        # check if the template path is a URL
        if template_path =~ URI.regexp

          # check if the template URL is valid and download it if it is
          valid_template_url = validate_template_url(template_path)
          template_dir = download_template_from_url(valid_template_url)

        else

          # check if the template path is a bundled template
          if AVAILABLE_TEMPLATES.include?(template_path)
            template_dir = File.join(__dir__, 'samples', template_path)
            Geb.log "Using bundled template #{template_path}."
          end # if

          # check if the template path is a directory and ontains a gab.config.yml file
          Geb.log_start "Validating template path #{template_dir} ... "
          raise InvalidTemplate.new unless File.directory?(template_dir)
          raise InvalidTemplate.new unless File.exist?("#{template_dir}/geb.config.yml")
          Geb.log "done."

        end # if

        # set the template path
        @template_path = template_dir

      end # unless skip_template

      # set the validated flag
      @validated = true

    end # def validate

    # create the site
    def create

      # raise an error if the site has not been validated
      raise UnvalidatedSiteAndTemplate.new unless @validated

      # create the site folder
      Geb.log_start "Creating site folder: #{@site_path} ... "
      # check if the folder already exists
      if File.directory?(@site_path)
        Geb.log "skipped, folder already exists."
      else
        Dir.mkdir(@site_path)
        Geb.log "done."
      end # if

      # check if we are skipping the template
      unless @template_path.nil?

        # copy the template files to the site folder
        Geb.log_start "Copying template files to site folder ... "
        FileUtils.cp_r("#{@template_path}/.", @site_path)
        Geb.log "done."

      end

    end # def create

    private

    # validate the template URL
    def validate_template_url(template_url)

      Geb.log_start "Validating template URL #{template_url} ... "

        # get the HTTP response for the template URL
      response = Net::HTTP.get_response(URI.parse(template_url))

      unless response.is_a?(Net::HTTPSuccess) && response['Content-Type'] == 'application/x-gzip'

        Geb.log ("Failed. Web server returned #{response.code}") unless response.is_a?(Net::HTTPSuccess)
        Geb.log ("Specified template is not a gzip archive") unless response['Content-Type'] == 'application/gzip'

        # add TEMPLATE_ARCHIVE_FILENAME to the URL (handle trailing slashes)
        template_url += '/' unless template_url.end_with?('/')
        template_url += TEMPLATE_ARCHIVE_FILENAME

        Geb.log_start ("Trying to find geb template using URL #{template_url} ... ");

        # get the HTTP response for the template URL
        response = Net::HTTP.get_response(URI.parse(template_url))

        # raise an error if the URL is not accessible
        raise InvalidTemplateURL.new("Web server returned #{response.code}") unless response.is_a?(Net::HTTPSuccess)

        # raise an error if the URL is not a tar.gz file
        raise InvalidTemplateURL.new("Specified template is not a gzip archive") unless ['application/x-gzip', 'application/gzip'].include?(response['Content-Type'])

      else

        # raise an error if the URL is not accessible
        raise InvalidTemplateURL.new("Web server returned #{response.code}") unless response.is_a?(Net::HTTPSuccess)

        # raise an error if the URL is not a tar.gz file
        raise InvalidTemplateURL.new("Specified template is not a gzip archive") unless ['application/x-gzip', 'application/gzip'].include?(response['Content-Type'])

      end # unless

      Geb::log("Found a gzip archive at template url #{template_url}.");

      return template_url

    end # validate_template_url

    # download the template into a temporary directory from the URl and extract it, return the path to the extracted template
    def download_template_from_url(template_url)

      # create a temporary directory
      tmp_dir = Dir.mktmpdir

      Geb.log_start "Downloading template from URL #{template_url} ... "

      # download the template archive
      File.open("#{tmp_dir}/#{TEMPLATE_ARCHIVE_FILENAME}", "wb") do |file|
        file.write(Net::HTTP.get(URI.parse(template_url)))
      end

      # extract the template archive using Open3
      _, stderr, status = Open3.capture3("tar", "-xzf", "#{tmp_dir}/#{TEMPLATE_ARCHIVE_FILENAME}", "-C", tmp_dir)

      # raise an error if the template extraction failed
      raise InvalidTemplateURL.new("Failed to extract template archive: #{stderr}") unless status.success?

      # check if the extracted template is valid
      raise InvalidTemplateURL.new("Invalid template archive") unless File.exist?("#{tmp_dir}/geb.config.yml")

      Geb.log "done. Extracted template to #{tmp_dir}."

      # return the path to the extracted template
      return tmp_dir

    end # ddef ownload_template_from_url



  end # class Site

end # module Geb
