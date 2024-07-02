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

  end # class Config
end # module Geb
