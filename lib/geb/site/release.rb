# frozen_string_literal: true
#
# Site release functionality, releasing the site, packaging site templates and assets
#
# @title Geb - Site - Release Module
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class Site
    module Release

      class SiteReleasingError < Geb::Error
        MESSAGE = "Site is already releasing.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class SiteReleasingError < Geb::Error

      # release the site
      # @raise SiteNotLoadedError if the site is not loaded
      def release

        # make sure the site is loaded, if not, raise an error
        raise Geb::Site::SiteNotLoadedError.new("Could not release the site.") unless @loaded

        # make sure the site is not already releasing, to prevent recursive releases
        raise Geb::Site::SiteReleasingError.new if @releasing

        # set the site to releasing
        @releasing = true

        # build the site
        build();

      ensure

        # set the site to not releasing
        @releasing = false

      end # def release

      # get the template archive path
      # @return [String] the template archive path within the release directory
      def get_template_archive_release_path
        return File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR, Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)
      end # def get_template_archive_release_path

      # get the site release output directory
      # @return [String] the site release directory
      def get_site_release_output_directory
        return File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR)
      end # def get_site_release_output_directory

      # check if the site has been released.
      # The site is considered released if the release directory exists and is not empty.
      # @return [Boolean] true if the site has been released, false otherwise
      def released?
        return Dir.exist?(get_site_release_output_directory()) && !Dir.empty?(get_site_release_output_directory())
      end # def released?

    end # module Build
  end # class Site
end # module Geb
