# frozen_string_literal: true
#
# Build command definition, based on Dry::CLI framework
# Builds the site, this is the core of what Geb does
#
# @title Geb - Build Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define build command
      class Build < Dry::CLI::Command

        # Command description, usage and examples
        desc "Build the full site, includes pages and assets"
        example [" ", "--skip_assets", "--skip_pages"]

        # Define command options
        option :skip_assets,  type: :boolean, default: false, desc: "Skip building assets (images, css, js)"
        option :skip_pages,   type: :boolean, default: false, desc: "Skip building pages"

        # Call method for the build command
        def call(**options)

          # initialize a new site and load the site from the current directory
          site = Geb::Site.new
          site.load(Dir.pwd)

          # build the pages unless the skip_pages option is set
          # it is important to build assets first as there may be pages in the assets directory
          Geb.log "Skipping building pages as told." if options[:skip_pages]
          site.build_pages unless options[:skip_pages]

          # build the assets (images, css, js) unless the skip_assets option is set
          Geb.log "Skipping building assets as told." if options[:skip_assets]
          site.build_assets unless options[:skip_assets]

          # put a smartarse message to the console if both options are set
          Geb.log "You told me to skip everything, so I did." if options[:skip_assets] && options[:skip_pages]

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message

        end # def call

      end # class Build < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
