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

      class InvalidTemplate < Geb::Error
        MESSAGE = "Invalid template site. Make sure the specified path is a directory and contains a valid gab.config.yml file.".freeze
        def initialize; super(MESSAGE); end
      end # class InvalidTemplate < Geb::Error

      class InvalidTemplateURL < Geb::Error
        MESSAGE = "Invalid template URL specified. Ensure the template URL is properly accessible and packaged Gab site using gab release --with_template".freeze
        def initialize; super(MESSAGE); end
      end # class InvalidTemplateURL < Geb::Error

      # define init command
      class Init < Dry::CLI::Command

        # define list of available templates and the option to control which one is selected (first one will be default)
        AVAILABLE_TEMPLATES = ['bootstrap_jquery', 'basic']

        # define the template archive filename
        TEMPLATE_ARCHIVE_FILENAME = 'geb-template.tar.gz'

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
        option :force,          type: :boolean, default: false,   desc: "Force overwrite of existing files and git repository. Use with caution."

        # call method for the init command
        def call(site_path:, **options)

          # initialize a new site object, this does all sorts of validations and checks, raises errors if something is wrong
          new_site = Geb::Site.new

          # validate the site
          new_site.validate(site_path, options[:template], options[:skip_template], options[:force])

          # validate proposed git repository in the site path if we are not skipping git, will raise error if git situation is unacceptable
          Geb::Git.validate_git_repo(site_path) unless options[:skip_git]

          # create the site folder and populate it with the template if we are not skipping the whole process
          new_site.create

          Geb.log "FUCK\n"
          exit 1
          puts "DUCK"
\

          if true

            # set the site path
            @site_path = site_path

            create_site_directory()
            unless options[:skip_git];        Geb::Git.create_git_repo();       else; puts "Skipping initializing git as told."; end
            unless options[:skip_locations];  create_locations();               else; puts "Skipping creating locations as told."; end
            unless options[:skip_template];   create_from_template(template);   else; puts "Skipping creating site from template as told."; end

          end

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message
          #raise e if ENV['TEST_MODE'] == 'true'
          #exit 1

        end # def call

        # ::: Methods ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

        # Create the site folder
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
          config_template_paths = template_config['template_paths']

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

          puts "Populating site from template: #{template_path}, found #{resolved_template_paths.count} entries."

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

              print "Creating file: #{destination_path} ... "
              if File.exist?(destination_path)
                puts "skipped, file already exists."
              else
                FileUtils.mkdir_p(File.dirname(destination_path))
                FileUtils.cp(resolved_path, destination_path)
                puts "done."
              end # if else

            end # if else

          end # each

          puts "Site generated from template #{template_path}."

        end # def create_from_template

        private

        # Check if the template is valid
        def get_template_path(specified_template_identifier)

          # initialize the return value to nil, hopefully we will find a valid template
          return_template_path = nil

          # check if the template identifier is specified
          if specified_template_identifier.nil?

            specified_template_identifier = AVAILABLE_TEMPLATES.first
            puts "No template specified, using default: #{specified_template_identifier}."

          else

            # download the template inta temporary directory if it is a URL
            return_template_path = download_site_template(specified_template_identifier) if specified_template_identifier.start_with?('http://', 'https://')

            # if we have a valid template path, return it
            return return_template_path if return_template_path

          end # if

          # check if the template identifier is in the available templates list
          if AVAILABLE_TEMPLATES.include?(specified_template_identifier)
            return_template_path = File.join(__dir__, '..', 'samples', specified_template_identifier)
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

        # Download the site template from a URL
        def download_site_template(template_url)

          puts "Attempting to download site template from: #{template_url}"

          # check if the URL ends with TEMPLATE_ARCHIVE_FILENAME, if not add it
          template_url = "#{template_url.chomp('/')}/#{TEMPLATE_ARCHIVE_FILENAME}" unless template_url.end_with?(TEMPLATE_ARCHIVE_FILENAME)



        end # def download_site_template

      end # class Init < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
