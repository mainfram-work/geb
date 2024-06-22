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
module Geb
  module CLI
    module Commands

      require 'fileutils'

      class DirectoryExistsError < Geb::Error
        MESSAGE = "Site folder already exists, please choose a different name or location.\nIf you want to use the existing site folder, use the --force option.".freeze
        def initialize; super(MESSAGE); end
      end # class DirectoryExistsError < Geb::Error

      class InsideGitRepoError < Geb::Error
        MESSAGE = "You are already inside a git repository, please choose a different location or use the --skip_git option.".freeze
        def initialize; super(MESSAGE); end
      end # class GitRepoExistsError < Geb::Error

      class GitRepoExistsError < Geb::Error
        MESSAGE = "Git repository already exists, please choose a different name or location or use the --skip_git option.".freeze
        def initialize; super(MESSAGE); end
      end # class GitRepoExistsError < Geb::Error

      # define init command
      class Init < Dry::CLI::Command

        # command description, usage and examples
        desc "Initialise geb site, creates folder locations, git repository and initial file structures"
        example ["new_site ", "new_site [options]", "new_site --skip_git --skip_config"]

        # define project name command argument
        argument :site_path,        type: :string,  required: true, desc: "Path to the site folder / site name"

        # define command options
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

        # call method for the init command
        def call(site_path:, skip_config:, skip_locations:, skip_assetfolders:, skip_git:, skip_index:, skip_site_manifest:, skip_snippets:, skip_js:, skip_css:, force:)

          # raise error if site folder already exists and force option is not set
          raise DirectoryExistsError.new if File.directory?(site_path) && !force

          # raise error if we are inside a git repository or git repository already exists and skip_git option is not set
          raise InsideGitRepoError.new if inside_git_repo? && !skip_git
          raise GitRepoExistsError.new if File.directory?(File.join(site_path, '.git'))  && !skip_git

          # set the site path 
          @site_path = site_path

          create_site_directory
          create_git_repo     unless skip_git
          create_config_file  unless skip_config

        rescue Geb::Error => e

          # print error message
          warn e.message
          #raise e if ENV['TEST_MODE'] == 'true'
          #exit 1

        end # def call

        # ::: Methods :::

        def create_site_directory

          print "Creating site folder: #{@site_path} ... "
          # check if the folder already exists
          if File.directory?(@site_path)
            puts "skipped, folder already exists."
          else
            Dir.mkdir(@site_path)
            puts "done."
          end # if 

        end # def create_site_directory

        # Create a new git repository in the site folder
        def create_git_repo

          print "Initialising git repository ... "

          # initialize the git repository
          system("git -C #{@site_path} init > /dev/null 2>&1")

          # create a .gitignore file
          File.open(File.join(@site_path, '.gitignore'), 'w') do |f|

            # ignore everything with the output and release folders
            f.puts "/output"
            f.puts "/release"
            f.puts "/.DS_Store"

          end # File.open

          puts "done."

        end # def execute_create_git_repo

        def create_config_file

          # copy the sample config file from the gem samples folder to the site folder
          print "Creating config file ... "
          
          puts
          puts "----------"
          puts File.expand_path('../../../geb/samples/geb.config.yml', __dir__)
          puts "----------"

          puts "done."


        end # def create_config_file

        private

        # Check if we are inside a git repository
        def inside_git_repo?
          system('git rev-parse --is-inside-work-tree > /dev/null 2>&1')
        end # def inside_git_repo?

      end # class Init < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
