# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Init command definition, based on Dry::CLI framework
#  Initializes the site, creates a basic folder structure and git repository
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include required libraries
require 'fileutils'
require 'yaml'

module Geb
  module CLI
    module Commands

      # define init command
      class Init < Dry::CLI::Command

        # command description, usage and examples
        desc "Initialise geb site, creates folder locations, git repository and initial file structures"
        example ["new_site ", "new_site [options]", "new_site --skip_template --skip_git"]

        # define project name command argument
        argument :site_path,        type: :string,  required: true, desc: "Path to the site folder / site name"

        # define command options
        option :template,       type: :string,  required: false,  desc: "Template site, either a path to a folder or one of the following: #{Geb::Defaults::AVAILABLE_TEMPLATES.join(", ")}. Default: #{Geb::Defaults::AVAILABLE_TEMPLATES.first}"
        option :skip_template,  type: :boolean, default: false,   desc: "Skip generating a site from template, ignores the template option."
        option :skip_git,       type: :boolean, default: false,   desc: "Skip initialising git repository"
        option :force,          type: :boolean, default: false,   desc: "Force overwrite of existing files and git repository. Use with caution."

        # attribute readers
        attr_reader :new_site

        # call method for the init command
        def call(site_path:, **options)

          # initialize a new site object, this does all sorts of validations and checks, raises errors if something is wrong
          @new_site = Geb::Site.new

          # validate the site
          @new_site.validate(site_path, options[:template], options[:skip_template], options[:force])

          # validate proposed git repository in the site path if we are not skipping git, will raise error if git situation is unacceptable
          Geb.log "Skipping git repository validation as told." if options[:skip_git]
          Geb::Git.validate_git_repo(site_path) unless options[:skip_git]

          # create the site folder and populate it with the template if we are not skipping the whole process
          @new_site.create

          # create the git repository if we are not skipping git
          Geb.log "Skipping git repository creation as told." if options[:skip_git]
          Geb::Git.create_git_repo(site_path) unless options[:skip_git]

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message

        end # def call

        # ::: Methods ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

      end # class Init < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
