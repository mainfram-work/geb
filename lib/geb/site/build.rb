# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Site building functionality, building assets and pages
#
#  Licence MIT
# -----------------------------------------------------------------------------

module Geb
  class Site
    module Build

      class SiteNotLoadedError < Geb::Error
        MESSAGE = "Site not loaded.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class SiteNotLoadedError < Geb::Error

      class FailedToOutputSite < Geb::Error
        MESSAGE = "Failed to output site.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class FailedToOutputSite < Geb::Error

      # build the site
      def build

        # make sure the site is laoded, if not, raise an error
        raise SiteNotLoadedError.new("Could not build the site.") unless @loaded

        # build the assets and pages
        build_assets()
        build_pages()

      end # def build

      # build the assets for the site
      # @exception SiteNotLoaded if the site is not loaded
      def build_assets

        # make sure the site is laoded, if not, raise an error
        raise SiteNotLoadedError.new("Could not build assets.") unless @loaded

        # get the site asset and output assets directory
        site_assets_dir = get_site_assets_directory()
        outout_assets_dir = File.join(get_site_output_directory(), site_assets_dir.gsub(@site_path, ""))

        Geb.log "Building assets for #{site_name}\n\n"

        # step through all the asset files and copy them to the output directory
        Dir.glob("#{site_assets_dir}/**/*").each do |asset_file|

          # skip directories
          next if File.directory?(asset_file)

          # get the relative path of the asset file and the destination path
          asset_relative_path = asset_file.gsub(site_assets_dir, "")
          asset_full_destination_path = File.join(outout_assets_dir, asset_relative_path)

          # check if the destination asset file exists
          if File.exist?(asset_full_destination_path)

            Geb.log " - skipping asset: #{asset_relative_path}"

          else

            Geb.log " - processing asset: #{asset_relative_path}"

            # create the output directory for the asset file
            output_dir = File.join(outout_assets_dir, File.dirname(asset_relative_path))
            FileUtils.mkdir_p(output_dir)

            # copy the asset file to the output directory
            FileUtils.cp(asset_file, output_dir)

          end # if else

        end # Dir.glob
        Geb.log "\nDone building assets for #{site_name}"

      end # def build_assets

      # build the pages for the site
      # @exception SiteNotLoaded if the site is not loaded
      def build_pages

        # make sure the site is laoded, if not, raise an error
        raise SiteNotLoadedError.new("Could not build pages.") unless @loaded

        # expire page template and partial caches
        Geb::Template.expire_cache
        Geb::Partial.expire_cache

        # find all HTML files in the site path that don't start with an underscore, with extention .html and .htm
        page_files = get_page_files(@site_path,
                                    Geb::Defaults::PAGE_EXTENSIONS,
                                    Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER,
                                    [get_site_output_directory(), get_site_release_directory()])

        Geb.log "Building #{page_files.length} pages for #{site_name}"

        # create a temporary directory
        Dir.mktmpdir do |tmp_dir|

          # iterate over the HTML files and build the pages
          page_files.each do |page_file|

            # create a new page object and buid the page into the temporary directory
            page = Geb::Page.new(self, page_file)
            page.build(tmp_dir)

          end # html_files.each
          Geb.log "\nDone building #{page_files.length} pages for #{site_name}"

          # attempt to write the site to the output directory
          begin

            # clear the output directory
            Geb.log_start "Clearing site output folder #{get_site_output_directory()} ... "
            clear_site_output_directory()
            Geb.log "done."

            # copy the files to the output directory
            Geb.log_start "Outputting site to #{get_site_output_directory()} ... "
            output_site(tmp_dir)
            Geb.log "done."

          rescue => e
            raise FailedToOutputSite.new(e.message)
          end # begin rescue

        end # Dir.mktmpdir

      end # def build_pages

      # get the site output directory
      # @return [String] the site output directory
      def get_site_output_directory
        return File.join(@site_path, Geb::Defaults::LOCAL_OUTPUT_DIR)
      end # def get_site_output_directory

      # get the page files in the specified path, with specified extentions and ignoring files that match the pattern
      # @param path [String] the path to the files
      # @param exts [Array] the extentions to look for, default is Geb::Defaults.PAGE_EXTENSIONS
      # @param ignore [Regexp] the pattern to ignore, default is Geb::Defaults.TEMPLATE_AND_PARTIAL_PREFIX
      def get_page_files(path, exts = Geb::Defaults::PAGE_EXTENSIONS, ignore_files_exp = Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER, ignore_directories = [])

        # get all files in the path with the specified extentions
        files = Dir.glob("#{path}/**/*{#{exts.join(',')}}")

        # reject files that match the ignore pattern and that are within the output or release directories
        files.reject! do |file|
          File.basename(file) =~ ignore_files_exp ||
          ignore_directories.any? { |dir| file.start_with?(dir) }
        end # files.reject!

        # return the array of matched file paths
        return files

      end # def get_page_files

      # clear the site output directory
      # @return [Nil]
      def clear_site_output_directory
        FileUtils.rm_rf(Dir.glob("#{get_site_output_directory()}/*"))
      end # def clear_site_output_directory

      # output the site from specified directory to the output directory. The specified directory is typically
      # a temporary directory where the site has been built.
      # @param output_dir [String] the directory to output
      # @return [Nil]
      def output_site(output_dir)
        FileUtils.cp_r("#{output_dir}/.", get_site_output_directory())
      end # def output_site

      # get the site assets directory
      # @return [String] the site assets directory
      def get_site_assets_directory
        return File.join(@site_path, Geb::Defaults::ASSETS_DIR)
      end # def get_site_assets_directory

    end # module Build
  end # class Site
end # module Geb
