# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Build command definition, based on Dry::CLI framework
#  Initializes the site, creates a basic folder structure and git repository
#
#  Licence MIT
# -----------------------------------------------------------------------------
module Geb
  module CLI
    module Commands

      # Define init command
      class Init < Dry::CLI::Command

        # Command description, usage and examples
        desc "Initialise geb site, creates folder locations, git repository and initial file structures"
        example [" ", "--skip_config", "--skip_locations", "--skip_assetfolders", "--skip_git", "--skip_index", "--skip_site_manifest", "--skip_snippets", "--skip_js", "--skip_css", "--force"]

        # Define command options
        option :skip_config,        type: :boolean, default: false, desc: "Skip generating config file"
        option :skip_locations,     type: :boolean, default: false, desc: "Skip generating generating Geb site folder locations"
        option :skip_assetfolders,  type: :boolean, default: false, desc: "Skip generating generating asset subfolders"
        option :skip_git,           type: :boolean, default: false, desc: "Skip initialising git repository"
        option :skip_index,         type: :boolean, default: false, desc: "Skip generating index page"
        option :skip_site_manifest, type: :boolean, default: false, desc: "Skip generating site manifest file"
        option :skip_snippets,      type: :boolean, default: false, desc: "Skip generating snippet files"
        option :skip_js,            type: :boolean, default: false, desc: "Skip generating default js file"
        option :skip_css,           type: :boolean, default: false, desc: "Skip generating default css file"
        option :force,              type: :boolean, default: false, desc: "Force overwrite of existing files"

        # Call method for the init command
        def call(skip_config:, skip_locations:, skip_assetfolders:, skip_git:, skip_index:, skip_site_manifest:, skip_snippets:, skip_js:, skip_css:, force:)

          puts "Initializing Geb project"

        end # def call

      end # class Init < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
