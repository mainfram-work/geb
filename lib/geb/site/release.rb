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

      # release the site
      def release

        # build the site first
        build();

      end # def release

      # get the site release directory
      # @return [String] the site release directory
      def get_site_release_directory
        return File.join(@site_path, Geb::Defaults::RELEASE_OUTPUT_DIR)
      end # def get_site_release_directory

    end # module Build
  end # class Site
end # module Geb
