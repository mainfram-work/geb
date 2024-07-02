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


require 'zlib'
require 'archive/tar/minitar'

module Geb
  class Site
    module Release

      # release the site
      def release

        # build the site first
        build();

        # get the site local and release directory
        site_release_directory  = get_site_release_directory()

        # clear the output directory
        Geb.log_start "Clearing site release folder #{site_release_directory} ... "
        clear_site_release_directory()
        Geb.log "done."

        # copy the files to the output directory
        Geb.log_start "Releasing site to #{site_release_directory} ... "
        copy_site_to_release_directory()
        Geb.log "done."

      end # def release

      # get the template archive path
      # @return [String] the template archive path within the release directory
      def get_template_archive_release_path
        return File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR, Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)
      end # def get_template_archive_release_path

      # get the site release directory
      # @return [String] the site release directory
      def get_site_release_directory
        return File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR)
      end # def get_site_release_directory

      # clear the site release directory
      # @return [Nil]
      def clear_site_release_directory
        FileUtils.rm_rf(Dir.glob("#{get_site_release_directory()}/*"))
      end # def clear_site_release_directory

      # output the site from local output to release directory.
      # @return [Nil]
      def copy_site_to_release_directory
        FileUtils.cp_r("#{get_site_output_directory()}/.", get_site_release_directory())
      end # def output_site

    end # module Build
  end # class Site
end # module Geb
