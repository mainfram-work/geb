# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Build command definition, based on Dry::CLI framework
#  Builds the site, this is the core of what Geb does
#
#  Licence MIT
# -----------------------------------------------------------------------------
module Geb
  module CLI
    module Commands

      # Define build command
      class Build < Dry::CLI::Command

        # Command description, usage and examples
        desc "Build the full site, includes pages and assets"
        example [" ", "--skip-assets", "--skip-pages"]

        # Define command options
        option :skip_assets,  type: :boolean, default: false, desc: "Skip building assets (images, css, js)"
        option :skip_pages,   type: :boolean, default: false, desc: "Skip building pages"

        # Call method for the build command
        def call(**options)

          puts "Building pages and assets"

        end # def call

      end # class Build < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
