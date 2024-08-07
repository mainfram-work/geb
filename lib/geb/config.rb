# frozen_string_literal: true
#
# Geb configuration.  It merges the geb.yml configuration file with the defaults.
#
# @title Geb - Command Registry
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# include the required libraries
require 'yaml'

module Geb
  class Config

    class ConfigFileNotFound < Geb::Error
      MESSAGE = "Could not find geb config file.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class ConfigFileNotFound < Geb::Error

    class DestinationDirMissing < Geb::Error
      MESSAGE = "Failed to generate configuration file, directory doesn't exist".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class DestinationDirMissing < Geb::Error

    class ConfigAlreadyExists < Geb::Error
      MESSAGE = "Failed to generate configuration file, it already exists".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class ConfigAlreadyExists < Geb::Error

    # check if the site directory specified has the required geb.config.yml file
    def self.site_directory_has_config?(site_path)
      File.exist?(File.join(site_path, Geb::Defaults::SITE_CONFIG_FILENAME))
    end # def self.site_directory_has_config?

    # initialize the site configuration\
    # @param site [Geb::Site] the site object
    # @raise ConfigFileNotFound if the site directory has no geb.config.yml file
    def initialize(site)

      # set the site path
      @site = site

      # make sure the site directory has the required geb.config.yml file
      raise ConfigFileNotFound.new("Site path [#{@site.site_path}] has no geb configuration.") unless Geb::Config.site_directory_has_config?(@site.site_path)

      # load the site configuration, if no configuration is found in the file, set it to an empty hash
      @config = YAML.load_file(File.join(@site.site_path, Geb::Defaults::SITE_CONFIG_FILENAME))
      @config ||= {}

    end # def initialize

    # generate the configuration file
    # @param destination_directory [String] the destination directory where to generate the configuration file
    # @raise DestinationDirMissing if the destination directory doesn't exist
    # @raise ConfigAlreadyExists if the configuration file already exists
    # @note the configuration file is generated without the following options (for security reasons):
    #  - site_name
    #  - remote_uri
    #  - remote_path
    def generate_config_file(destination_directory)

      # make sure the destination directory exists and there is no configuration file
      raise DestinationDirMissing.new("Specified directory [#{destination_directory}] missing.") unless File.directory?(destination_directory)
      raise ConfigAlreadyExists.new("Specified directory [#{destination_directory}] already has geb config.") if File.exist?(File.join(destination_directory, Geb::Defaults::SITE_CONFIG_FILENAME))

      # initialize a new hash to store the configuration
      new_config = {}

      # add existing configuration to the new configuration
      new_config['local_port'] = local_port             if local_port
      new_config['output_dir'] = output_dir             unless output_dir == Geb::Defaults::OUTPUT_DIR
      new_config['assets_dir'] = assets_dir             unless assets_dir == Geb::Defaults::ASSETS_DIR
      new_config['page_extensions']   = page_extensions   unless page_extensions == Geb::Defaults::PAGE_EXTENSIONS
      new_config['template_paths']    = template_paths    if template_paths
      new_config['template_message']  = template_message  if template_message
      new_config['template_and_partial_identifier'] = template_and_partial_identifier unless template_and_partial_identifier == Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER

      # check if site variables are used
      if @config['site_variables']

        # initialize local and release site variables
        new_config['site_variables'] = {}
        new_config['site_variables']['local'] = {}
        new_config['site_variables']['release'] = {}

        # check if any local variables are used
        new_config['site_variables']['local'] = @config['site_variables']['local'] if @config['site_variables']['local']

        # check if any release variables are used, add only variable names and blank values
        if @config['site_variables']['release']

          # copy the local variables to the release variables, but set the values to emtpy strings
          new_config['site_variables']['release'] = @config['site_variables']['release'].keys.each_with_object({}) { |key, hash| hash[key] = '' }

        end # if

      end # if

      # write the new configuration to the destination directory
      File.open(File.join(destination_directory, Geb::Defaults::SITE_CONFIG_FILENAME), 'w') do |file|

        # generate configuration file header
        file.write("#\n")
        file.write("# Geb #{Geb::VERSION} Site Configuration\n")
        file.write("# Generated by site template for #{site_name}\n")
        file.write("#\n")
        file.write("# For more information on the configuration options, see the fully document file at: \n")
        file.write("# https://github.com/mainfram-work/geb/blob/main/lib/geb/samples/geb.config.yml\n")
        file.write("#\n")

        # write the new configuration to the file
        file.write(new_config.to_yaml)

      end # File.open

    end # def generate_config_file

    # get the configured site name, if not set, use the site directory name
    # @return [String] the site name
    def site_name
      return @config['site_name'] || File.basename(@site.site_path)
    end # def site_name

    # get the configured remote uri
    # @return [String] the remote uri
    def remote_uri
      return @config['remote_uri'] || nil
    end # def remote_uri

    # get the configured remote path
    # @return [String] the remote path
    def remote_path
      return @config['remote_path'] || nil
    end # def remote_path

    # get the configured local port
    # @return [Integer] the local port
    def local_port
      return @config['local_port'] || nil
    end # def local_port

    # get the configured output directory
    # @return [String] the output directory
    # @note the assets directory is relative to the site root
    def output_dir
      return @config['output_dir'] || Geb::Defaults::OUTPUT_DIR
    end # def output_dir

    # get the configured assets directory
    # @return [String] the assets directory
    # @note the assets directory is relative to the site root
    def assets_dir
      return @config['assets_dir'] || Geb::Defaults::ASSETS_DIR
    end # def assets_dir

    # get the configured page extensions
    # @return [Array] the page extensions
    def page_extensions
      return @config['page_extensions'] || Geb::Defaults::PAGE_EXTENSIONS
    end # def page_extensions

    # get the configured template and partial identifier
    # @return [Regexp] the template and partial identifier
    def template_and_partial_identifier
      return @config['template_and_partial_identifier'] || Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER
    end # def template_and_partial_identifier

    # get the configured template paths
    # @return [Array] the template paths
    # @note the template paths are relative to the site root
    def template_paths
      return @config['template_paths'] || []
    end # def template_paths

    # get the configured template message
    # @return [String] the template message
    # @note the template message is displayed after the template has been used.
    def template_message
      return @config['template_message'] || nil
    end # def template_message

    # get the configured partial paths
    # @return [Array] the partial paths
    # @note the configured site variables are different depending on the environment (local or release)
    def get_site_variables

      # check if the site is releasing and return the site variables
      environment = (@site.releasing ? 'release' : 'local')

      # return the site variables for the environment
      return( @config['site_variables']&.[](environment) || {}).dup

    end # def get_site_variables

  end # class Config
end # module Geb
