# frozen_string_literal: true
#
# This module is responsible for handling site templates, including downloading
# and extracting templates from remote URLs.
#
# @title Geb - Site - Template Module
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class Site
    module Template

      class InvalidTemplateURL < Geb::Error
        MESSAGE = "Invalid template URL specified. Ensure the template URL is properly accessible and packaged Gab site using geb release --with_template".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class InvalidTemplateURL < Geb::Error

      class InvalidTemplateSpecification < Geb::Error
        MESSAGE = "Template has no template paths defined in geb.config.yml".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class InvalidTemplateSpecification < Geb::Error

      # copy the template from the specified path to the site path. It uses template_paths from the configuration
      # file to find the template. If the template is not found, it raises an error.
      # @raise UnvalidatedSiteAndTemplate if the site has not been validated
      # @raise InvalidTemplateSpecification if the template path is not a directory or has no geb.config.yml file
      # @raise InvalidTemplateSpecification if the resolved template paths are empty
      # @raise InvalidTemplateSpecification if the site cannot be loaded from the template path
      # @raise InvalidTemplateSpecification if the resolved template paths cannot be copied to the site path
      def copy_template_from_path

        # raise an error if the site has not been validated
        raise UnvalidatedSiteAndTemplate.new unless @validated

        # check if the template path is a directory
        raise InvalidTemplateSpecification.new("Template path [#{@template_path}] is not a directory") unless File.directory?(@template_path)

        # check if the template path has a geb.config.yml file
        raise InvalidTemplateSpecification.new("Template path [#{@template_path}] has no geb.config.yml file") unless Geb::Config.site_directory_has_config?(@template_path)

        # create a site for the template, load it and get the site configuration
        Geb.log_start "Loading template site from path #{@template_path} ... "
        template_site = Geb::Site.new
        Geb.no_log { template_site.load(@template_path) } # suppress logging for loading the template site
        Geb.log "done."

        # resolve template paths to directories and files to be copied
        Geb.log_start "Resolving directories and files from template site to copy ... "
        resolved_template_paths = template_site.site_config.template_paths.flat_map do |template_file_path|
          Dir.glob(File.join(template_site.site_path, template_file_path))
        end
        Geb.log "done. Found #{resolved_template_paths.count} directories and files."

        # if the resolved template paths are empty, raise an error
        raise InvalidTemplateSpecification.new("Failed to load site from [#{template_site.site_path}]") if resolved_template_paths.empty?

        # copy the resolved template paths to the site path
        Geb.copy_paths_to_directory(template_site.site_path, resolved_template_paths, @site_path)

        # display the template message if it has been configured within the template
        Geb.log_important template_site.site_config.template_message if template_site.site_config.template_message

      end # def copy_template_from_path

      # bundle the site as a template archive
      # @raise SiteNotFoundError if the site is not loaded
      # @raise InvalidTemplateSpecification if the template paths are not specified
      # @raise InvalidTemplateSpecification if the resolved template paths are empty
      # @raise InvalidTemplateSpecification if the template archive cannot be created
      # @note template will be bundled with the geb.config.yml file, so the site can be re-created from the template
      def bundle_template

        # raise an error if the site is not loaded
        raise Geb::Site::SiteNotFoundError.new("Site not loaded") unless @loaded

        # resolve template paths to directories and files to be copied
        Geb.log_start "Resolving directories and files to include in the template archive ... "
        resolved_template_paths = @site_config.template_paths.flat_map do |template_file_path|
          Dir.glob(File.join(@site_path, template_file_path))
        end
        Geb.log "done. Found #{resolved_template_paths.count} directories and files."

        # if the resolved template paths are empty, raise an error
        raise InvalidTemplateSpecification.new("Config template_paths not specified.") if resolved_template_paths.empty?

        # create a temporary directory for the site template
        tmp_archive_directory = Dir.mktmpdir

        # copy the resolved paths to the temporary directory
        Geb.log "Copying directories and files to the template archive directory #{tmp_archive_directory}"
        Geb.copy_paths_to_directory(@site_path, resolved_template_paths, tmp_archive_directory)
        Geb.log "Done copying directories and files to the template archive directory."

        # create a geb config file in the temporary directory
        Geb.log_start "Generating geb.config.yml in the template archive directory ... "
        @site_config.generate_config_file(tmp_archive_directory)
        Geb.log "done."

        # create a template archive with files from the temporary directory into the release directory
        output_archive_filename = File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR, Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)
        Geb.log_start "Creating template archive in [#{output_archive_filename}] ... "
        Open3.capture3("tar", "-czvf", output_archive_filename, "-C", tmp_archive_directory, ".")
        Geb.log "done."

      end # def bundle_template

      # validate the template URL. It checks if the URL is accessible and is a tar.gz file.
      # if the URL is not accessible, it tries to find the template by appending TEMPLATE_ARCHIVE_FILENAME
      # this is to facilitate specifying a top level URL. The method returns the URL if it is valid.
      # @param template_url [String] the URL to the template
      # @raise InvalidTemplateURL if the URL is not accessible or is not a tar.gz file
      # @return [String] the validated template URL
      def validate_template_url(template_url)

        # get the HTTP response for the template URL
        Geb.log_start "Validating template URL #{template_url} ... "
        response = fetch_http_response(template_url)
        Geb.log "done."

        # check if the URL is accessible and is a tar.gz file, if not, try to find by appending TEMPLATE_ARCHIVE_FILENAME
        unless response.is_a?(Net::HTTPSuccess) && Geb::Defaults::HTTP_TEMPLATE_CONTENT_TYPES.include?(response['Content-Type'])

          # check if the URL already has the TEMPLATE_ARCHIVE_FILENAME appended, if not, append it and try again
          unless template_url.end_with?(Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)

            # add TEMPLATE_ARCHIVE_FILENAME to the URL (handle trailing slashes)
            template_url += '/' unless template_url.end_with?('/')
            template_url += Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME

            Geb.log ("Failed. Web server returned #{response.code}, trying to re-try with url #{template_url}") unless response.is_a?(Net::HTTPSuccess)
            Geb.log ("Specified template is not a gzip archive, trying to re-try with url #{template_url}")     unless Geb::Defaults::HTTP_TEMPLATE_CONTENT_TYPES.include?(response['Content-Type'])
            Geb.log_start ("Trying to find geb template using URL #{template_url} ... ");

            # get the HTTP response for the template URL (now modified to include the archive filename)
            response = fetch_http_response(template_url)

          end # unless

        end # unless

        # raise an error if the URL is not accessible and is not a tar.gz file
        raise InvalidTemplateURL.new("Web server returned #{response.code}")      unless response.is_a?(Net::HTTPSuccess)
        raise InvalidTemplateURL.new("Specified template is not a gzip archive")  unless Geb::Defaults::HTTP_TEMPLATE_CONTENT_TYPES.include?(response['Content-Type'])

        Geb::log("Found a gzip archive at template url #{template_url}.");

        return template_url

      end # validate_template_url

      # download the template into a temporary directory from the URl and extract it,
      # return the path to the extracted template
      # @param template_url [String] the URL to the template
      # @raise InvalidTemplateURL if the template extraction fails
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

      # fetch the HTTP response for the URL
      # @param url [String] the URL to fetch
      # @raise InvalidTemplateURL if the URL is not accessible
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

      # check if the template directory exists
      def template_directory_exists?(template_path)
        File.directory?(template_path)
      end # def template_directory_exists?

      # check if the URL is a valid URL
      def is_url?(url)
        url =~ URI::DEFAULT_PARSER.make_regexp
      end # def is_url?

      # check if the template is a bundled template
      def is_bundled_template?(template)
        Geb::Defaults::AVAILABLE_TEMPLATES.include?(template)
      end # def is_bundled_template?

    end # module Template
  end # class Site
end # module Geb
