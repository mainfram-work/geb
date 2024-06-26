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

    class SiteAlreadyValidated < Geb::Error
      MESSAGE = "Proposed site and template have not been validated. This is an internal error".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class SiteAlreadyValidated < Geb::Error

    class UnvalidatedSiteAndTemplate < Geb::Error
      MESSAGE = "You are trying to create an unvalidated site. This is an internal error".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class UnvalidatedSiteAndTemplate < Geb::Error

    # attribute readers
    attr_reader :site_path, :template_path, :validated

    # site constructor
    # initializes the site object and attributes
    def initialize

      @validated = false
      @site_path = nil
      @template_path = nil

    end # def initialize

    # validate the site path and template path, and set the validated flag
    # it executes the following validations:
    #   - make sure the site is not already validated
    #   - make sure the site path is valid, consider force option
    #   - if template path is nil, use the default template
    #   - if template path is a URL, validate the URL and download the template
    #   - if template path is a directory, check if it has a gab.config.yml file
    # @param site_path      [String]  the path to the site folder
    # @param template_path  [String]  the path to the site template, default is nil, can be a URL, directory or a bundled template identifier
    # @param skip_template  [Boolean] skip the template validation, default is false
    # @param force          [Boolean] force the site creation, default is false
    # @exception SiteAlreadyValidated if the site has already been validated
    # @exception DirectoryExistsError if the site folder already exists and force option is not set
    # @exception InvalidTemplate if the template path is invalid
    # @exception InvalidTemplateURL if the template URL is invalid
    # @return [Nil]
    def validate(site_path, template_path = nil, skip_template = false, force = false)

      # raise an error if the site has already been validated
      raise SiteAlreadyValidated.new if @validated

      Geb.log_start "Validating site path #{site_path} ... "
      # raise error if site folder already exists and force option is not set
      raise DirectoryExistsError.new if site_directory_exists?(site_path) && !force
      @site_path = site_path
      Geb.log('done.')

      Geb.log("Skipping template validation as told.") if skip_template

      # check if we are skipping the template
      unless skip_template

        # initialize the template directory path.
        template_dir = nil

        # if the template path is nil, use the first bundled template name
        if template_path.nil? || template_path.empty?

          Geb.log "No template specified, using default: #{Geb::Defaults::DEFAULT_TEMPLATE}."
          template_dir = Geb::Defaults::DEFAULT_TEMPLATE_DIR

        end # if

        # check if the template path is a URL
        if is_url?(template_path) && template_dir.nil?

          # check if the template URL is valid and download it if it is
          valid_template_url = validate_template_url(template_path)
          template_dir       = download_template_from_url(valid_template_url)

        end # if

        # check if the template path is a bundled template
        if template_dir.nil? && is_bundled_template?(template_path)

          template_dir = File.join(Geb::Defaults::BUNDLED_TEMPLATES_DIR, template_path)
          Geb.log "Specified template is a Geb sample: #{template_path}, using it as site template."

        end # if

        # set the template dir to specified template path if template dir is still nil
        template_dir = template_path if template_dir.nil? # this is the case when the template is a local directory

        # check if the template path is a directory and ontains a gab.config.yml file
        Geb.log_start "Validating template path #{template_dir.to_s} ... "
        raise InvalidTemplate.new if template_dir.nil?
        raise InvalidTemplate.new unless template_directory_exists?(template_dir)
        raise InvalidTemplate.new unless template_directory_has_config?(template_dir)
        Geb.log "done."

        # set the template path
        @template_path = template_dir

      end # unless skip_template

      # set the validated flag
      @validated = true

    end # def validate

    # create the site. It assumes and checks that the site has been validated first.
    # the reason we don't just call validate from here is that we want to separate
    # the validation from the creation for CLI UI purposes.
    # performs the following steps
    #   - raise an error if the site has not been validated
    #   - create the site folder, if it exists, just skip it
    #   - copy the template files to the site folder if the template path is set
    #   - create the output folders
    # @exception UnvalidatedSiteAndTemplate if the site has not been validated
    # @return [Nil]
    def create

      # raise an error if the site has not been validated
      raise UnvalidatedSiteAndTemplate.new unless @validated

      # check if the folder already exists, if we are here and it does, just skip it, validation would have considered a force option
      Geb.log_start "Creating site folder: #{@site_path} ... "
      if site_directory_exists?(@site_path)
        Geb.log "skipped, folder already exists."
      else
        Dir.mkdir(@site_path)
        Geb.log "done."
      end # if

      Geb.log("Skipping template creation as told.") if @template_path.nil?

      # check if we are skipping the template
      unless @template_path.nil?

        # copy the template files to the site folder
        Geb.log_start "Copying template files to site folder ... "
        FileUtils.cp_r("#{@template_path}/.", @site_path)
        Geb.log "done."

      end # unless

      # create the output folders
      Geb.log_start "Creating: local and release output folders ..."
      FileUtils.mkdir_p(File.join(@site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
      FileUtils.mkdir_p(File.join(@site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))
      Geb.log "done."

    end # def create

    private

    # validate the template URL. It checks if the URL is accessible and is a tar.gz file.
    # if the URL is not accessible, it tries to find the template by appending TEMPLATE_ARCHIVE_FILENAME
    # this is to facilitate specifiying a top level URL. The method returns the URL if it is valid.
    # @param template_url [String] the URL to the template
    # @exception InvalidTemplateURL if the URL is not accessible or is not a tar.gz file
    # @return [String] the validated template URL
    def validate_template_url(template_url)

      # get the HTTP response for the template URL
      Geb.log_start "Validating template URL #{template_url} ... "
      response = fetch_http_response(template_url)
      Geb.log "done."

      # check if the URL is accessible and is a tar.gz file, if not, try to find by appending TEMPLATE_ARCHIVE_FILENAME
      unless response.is_a?(Net::HTTPSuccess) && ['application/x-gzip', 'application/gzip'].include?(response['Content-Type'])

        # check if the URL already has the TEMPLATE_ARCHIVE_FILENAME appended, if not, append it and try again
        unless template_url.end_with?(Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)

          # add TEMPLATE_ARCHIVE_FILENAME to the URL (handle trailing slashes)
          template_url += '/' unless template_url.end_with?('/')
          template_url += Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME

          Geb.log ("Failed. Web server returned #{response.code}, trying to re-try with url #{template_url}") unless response.is_a?(Net::HTTPSuccess)
          Geb.log ("Specified template is not a gzip archive, trying to re-try with url #{template_url}") unless ['application/x-gzip', 'application/gzip'].include?(response['Content-Type'])
          Geb.log_start ("Trying to find geb template using URL #{template_url} ... ");

          # get the HTTP response for the template URL (now modified to include the archive filename)
          response = fetch_http_response(template_url)

        end # unless

      end # unless

      # raise an error if the URL is not accessible and is not a tar.gz file
      raise InvalidTemplateURL.new("Web server returned #{response.code}")      unless response.is_a?(Net::HTTPSuccess)
      raise InvalidTemplateURL.new("Specified template is not a gzip archive")  unless ['application/x-gzip', 'application/gzip'].include?(response['Content-Type'])

      Geb::log("Found a gzip archive at template url #{template_url}.");

      return template_url

    end # validate_template_url

    # download the template into a temporary directory from the URl and extract it,
    # return the path to the extracted template
    # @param template_url [String] the URL to the template
    # @exception InvalidTemplateURL if the template extraction fails
    # @return [String] the path to the extracted template
    def download_template_from_url(template_url)

      # create a temporary directory
      tmp_dir = Dir.mktmpdir

      Geb.log_start "Downloading template from URL #{template_url} ... "

      # download the template archive
      File.open("#{tmp_dir}/#{Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME}", "wb") do |file|
        file.write(Net::HTTP.get(URI.parse(template_url)))
      end

      # extract the template archive using Open3
      _, stderr, status = Open3.capture3("tar", "-xzf", "#{tmp_dir}/#{Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME}", "-C", tmp_dir)

      # raise an error if the template extraction failed or the geb config file is not present
      raise InvalidTemplateURL.new("Failed to extract template archive: #{stderr}") unless status.success?
      raise InvalidTemplateURL.new("Invalid template archive") unless File.exist?("#{tmp_dir}/geb.config.yml")

      Geb.log "done. Extracted template to #{tmp_dir}."

      # return the path to the extracted template
      return tmp_dir

    end # def ownload_template_from_url

    # ::: Whole bunch of helper methods. These exists so testing is easier :::::::::::::::::::::::

    # fetch the HTTP response for the URL
    # @param url [String] the URL to fetch
    # @exception InvalidTemplateURL if the URL is not accessible
    # @return [Net::HTTPResponse] the HTTP response
    def fetch_http_response(url)
      return_response = nil
      begin
        return_response = Net::HTTP.get_response(URI.parse(url))
      rescue StandardError => e
        raise InvalidTemplateURL.new("HTTP error: #{e.message}")
      end # begin
      return return_response
    end # def fetch_http_response

    # check if the site directory exists
    def site_directory_exists?(site_path)
      File.directory?(site_path)
    end # def site_directory_exists?

    # check if the template directory exists
    def template_directory_exists?(template_path)
      File.directory?(template_path)
    end # def template_directory_exists?

    # check if the template directory specified has the required gab.config.yml file
    def template_directory_has_config?(template_path)
      File.exist?(File.join(template_path, Geb::Defaults::SITE_CONFIG_FILENAME))
    end # def template_directory_has_config?

    # check if the URL is a valid URL
    def is_url?(url)
      url =~ URI::DEFAULT_PARSER.make_regexp
    end # def is_url?

    # check if the template is a bundled template
    def is_bundled_template?(template)
      Geb::Defaults::AVAILABLE_TEMPLATES.include?(template)
    end # def is_bundled_template?

  end # class Site

end # module Geb
