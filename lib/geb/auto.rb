# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Auto command definition, based on Dry::CLI framework
#  Monitor project for file changes and build the site if any file changes
#
#  Licence MIT
# -----------------------------------------------------------------------------
module Geb
  module CLI
    module Commands

      # Define auto command
      class Auto < Dry::CLI::Command

        # Command description, usage and examples
        desc "Watch for changes and build the site when a file changes"
        example [" ", "--skip-assets-build", "--skip-pages-build"]

        # Define command options
        option :skip_assets_build,  type: :boolean, default: false, desc: "Skip building assets (images, css, js)"
        option :skip_pages_build,   type: :boolean, default: false, desc: "Skip building pages"

        # Call method for the auto command
        def call(skip_assets_build:, skip_pages_build:)

          puts "Auto Building Site"

        end # def call

      end # class Auto < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
