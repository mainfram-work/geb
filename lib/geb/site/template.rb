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
        MESSAGE = "Invalid template URL specified. Ensure the template URL is properly accessible and packaged Gab site using gab release --with_template".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class InvalidTemplateURL < Geb::Error

      # validate the template URL. It checks if the URL is accessible and is a tar.gz file.
      # if the URL is not accessible, it tries to find the template by appending TEMPLATE_ARCHIVE_FILENAME
      # this is to facilitate specifiying a top level URL. The method returns the URL if it is valid.
      # @param template_url [String] the URL to the template
      # @raise InvalidTemplateURL if the URL is not accessible or is not a tar.gz file
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

    end # module Template
  end # class Site
end # module Geb
