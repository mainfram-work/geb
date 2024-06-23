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
      require 'yaml'

      class DirectoryExistsError < Geb::Error
        MESSAGE = "Site folder already exists, please choose a different name or location.\nIf you want to use the existing site folder, use the --force option.".freeze
        def initialize; super(MESSAGE); end
      end # class DirectoryExistsError < Geb::Error

      class InsideGitRepoError < Geb::Error
        MESSAGE = "You are already inside a git repository, please choose a different location or use the --skip_git option.".freeze
        def initialize; super(MESSAGE); end
      end # class InsideGitRepoError < Geb::Error

      class GitRepoExistsError < Geb::Error
        MESSAGE = "Git repository already exists, please choose a different name or location or use the --skip_git option.".freeze
        def initialize; super(MESSAGE); end
      end # class GitRepoExistsError < Geb::Error

      class InvalidTemplate < Geb::Error
        MESSAGE = "Invalid template site. Make sure the specified path is a directory and contains a valid gab.config.yml file.".freeze
        def initialize; super(MESSAGE); end
      end # class InvalidTemplate < Geb::Error

      # define init command
      class Init < Dry::CLI::Command

        # define list of available templates and the option to control which one is selected (first one will be default)
        AVAILABLE_TEMPLATES = ['bootstrap_jquery', 'basic']

        # command description, usage and examples
        desc "Initialise geb site, creates folder locations, git repository and initial file structures"
        example ["new_site ", "new_site [options]", "new_site --skip_git --skip_config"]

        # define project name command argument
        argument :site_path,        type: :string,  required: true, desc: "Path to the site folder / site name"

        # define command options
        option :template,       type: :string,  required: false,  desc: "Template site, either a path to a folder or one of the following: #{AVAILABLE_TEMPLATES.join(", ")}. Default: #{AVAILABLE_TEMPLATES.first}"
        option :skip_locations, type: :boolean, default: false,   desc: "Skip generating generating Geb site folder locations."
        option :skip_template,  type: :boolean, default: false,   desc: "Skip generating a site from template, ignores the template option."
        option :skip_git,       type: :boolean, default: false,   desc: "Skip initialising git repository"
        option :force,          type: :boolean, default: false,   desc: "Force overwrite of existing files"

        # call method for the init command
        def call(site_path:, **options)

          # raise error if site folder already exists and force option is not set
          raise DirectoryExistsError.new if File.directory?(site_path) && !options[:force]

          # raise error if we are inside a git repository or git repository already exists and skip_git option is not set
          raise InsideGitRepoError.new if inside_git_repo? && !options[:skip_git]
          raise GitRepoExistsError.new if File.directory?(File.join(site_path, '.git'))  && !options[:skip_git]

          # raise error if the template site is not valid
          template = options[:skip_template] ? nil : get_template_path(options[:template])
          raise InvalidTemplate.new if !template && !options[:skip_template]

          # set the site path
          @site_path = site_path

          create_site_directory()
          unless options[:skip_git];        create_git_repo();                else; puts "Skipping initializing git as told."; end
          unless options[:skip_locations];  create_locations();               else; puts "Skipping creating locations as told."; end
          unless options[:skip_template];   create_from_template(template);   else; puts "Skipping creating site from template as told."; end

        rescue Geb::Error => e

          # print error message
          warn e.message
          #raise e if ENV['TEST_MODE'] == 'true'
          #exit 1

        end # def call

        # ::: Methods ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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

            # ignore everything with the output folder
            f.puts "/output"
            f.puts "/.DS_Store"

          end # File.open

          puts "done."

        end # def execute_create_git_repo

        # Create the site folder output structure
        def create_locations

          # create the site folder structure
          ["output", "output/local", "output/release"].each do |folder|

            # get the new folder path
            new_folder = File.join(@site_path, folder)

            print "Creating: #{new_folder} ... "

            # check if the folder already exists
            if File.directory?(new_folder)
              puts "skipped, folder already exists."
            else
              Dir.mkdir(new_folder)
              puts "done."
            end # if else

          end # each

        end # def create_locations

        # Create the site folder structure from a template
        def create_from_template(template_path)

          # read the config file from the template path
          template_config_file = File.join(template_path, 'geb.config.yml')
          template_config = YAML.load_file(template_config_file)

          # get the list of template paths from the config file
          config_template_paths = template_config['site_template']

          # initalise a list of resolved paths to copy
          resolved_template_paths = []

          # step through the template paths and copy the files or directories
          config_template_paths.each do |config_path|

            # check if the current config path has a *, if so, we need to get a list of files otherwise just copy the filename
            if config_path.include?('*')
              resolved_template_paths.concat(Dir.glob(File.join(template_path, config_path)))
            else
              resolved_template_paths << File.join(template_path, config_path)
            end # if else

          end # each

          # add the template config file to the resolved paths if it is not already there
          resolved_template_paths << File.join(template_path, 'geb.config.yml') unless resolved_template_paths.include?(File.join(template_path, 'geb.config.yml'))

          # step through the resolved paths and copy the files or directories
          resolved_template_paths.each do |resolved_path|

            # build the destination path
            destination_path = resolved_path.gsub(template_path, @site_path)

            # check if the resolved path is a directory or a file
            if File.directory?(resolved_path)

              print "Creating directory: #{destination_path} ... "
              if File.directory?(destination_path)
                puts "skipped, directory already exists."
              else
                FileUtils.cp_r(resolved_path, destination_path, preserve: true)
                puts "done."
              end # if else

            else

              print "Copying file: #{destination_path} ... "
              if File.exist?(destination_path)
                puts "skipped, file already exists."
              else
                FileUtils.mkdir_p(File.dirname(destination_path))
                FileUtils.cp(resolved_path, destination_path)
                puts "done."
              end # if else

            end # if else

          end # each

        end # def create_from_template

        private

        # Check if the template is valid
        def get_template_path(specified_template_identifier)

          return_template_path = nil

          # check if the template identifier is specified
          if specified_template_identifier.nil?
            specified_template_identifier = AVAILABLE_TEMPLATES.first
            puts "No template specified, using default: #{specified_template_identifier}."
          end # if

          # check if the template identifier is in the available templates list
          if AVAILABLE_TEMPLATES.include?(specified_template_identifier)
            return_template_path = File.join(__dir__, 'samples', specified_template_identifier)
            puts "Specified template is a Geb sample: #{specified_template_identifier}, using it as site template."
          else
            # check if the template identifier is a valid path
            if File.directory?(specified_template_identifier)
              return_template_path = specified_template_identifier
              puts "Specified template is a valid path: #{specified_template_identifier}, using it as site template."
            else
              puts "Specified template is not a Geb sample or a valid path: #{specified_template_identifier}."
            end
          end # if else

          # check if the template path has a valid config file
          unless File.exist?(File.join(return_template_path, 'geb.config.yml'))
            puts "Specified template path does not contain a valid geb.config.yml file."
            return_template_path = nil
          end # unless

          # return the template path
          return return_template_path

        end # def valid_template?

        # Check if we are inside a git repository
        def inside_git_repo?
          system('git rev-parse --is-inside-work-tree > /dev/null 2>&1')
        end # def inside_git_repo?

      end # class Init < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
