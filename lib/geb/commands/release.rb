# frozen_string_literal: true
#
# Release command definition, based on Dry::CLI framework
# Builds the site into the release directory with optional template archive
#
# @title Geb - Release Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @todo Consider some option or check to see if the release would override previous release --with_template
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define release command
      class Release < Dry::CLI::Command

        # Command description, usage and examples
        desc "Builds the release version of the site (pages and assets)"
        example [" ", "--with_template"]

        # Define command options
        option :with_template,  type: :boolean, default: false, desc: "Build the release site with a template archive so you can share it."

        # Call method for the release command
        def call(**options)

          # initialise a new site and load the site from the current directory
          site = Geb::Site.new
          site.load(Dir.pwd)

          # create a new release for the site
          site.release()

          # bundle the site with a template archive if the with_template option is set
          site.bundle_template() if options[:with_template]

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message

        end # def call

      end # class Release < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
