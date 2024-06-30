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

          puts "Building pages and assets for release"

        end # def call

      end # class Release < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
