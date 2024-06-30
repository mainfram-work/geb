# frozen_string_literal: true
#
# Upload command definition, based on Dry::CLI framework
# Upload the site to a remote server
#
# @title Geb - Upload Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define upload command
      class Upload < Dry::CLI::Command

        # Command description, usage and examples
        desc "Upload the site to the remote server"
        example [" ", "--skip_build", "--skip_assets_build", "--skip_pages_build"]

        # Define command options
        option :skip_build,         type: :boolean, default: false, desc: "Skip building pages and assets"
        option :skip_assets_build,  type: :boolean, default: false, desc: "Skip building assets (images, css, js)"
        option :skip_pages_build,   type: :boolean, default: false, desc: "Skip building pages"

        # Call method for the upload command
        def call(skip_build:, skip_assets_build:, skip_pages_build:)

          puts "Uploading site"

        end # def call

      end # class Upload < Dry::CLI::Upload

    end # module Commands
  end # module CLI
end # module Geb
