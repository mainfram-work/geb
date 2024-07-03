# frozen_string_literal: true
#
# Represents a site object, handles creation, building and management of sites.
#
# @title Geb - Site
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# include the required libraries
require 'uri'
require 'net/http'
require 'tmpdir'
require 'open3'
require 'shellwords'

# include site modules
require_relative 'site/core'
require_relative 'site/build'
require_relative 'site/release'
require_relative 'site/template'
require_relative 'site/remote'

module Geb
  class Site

    # include site sub-modules
    include Geb::Site::Core       # core site functionality, loading, validation and creation
    include Geb::Site::Build      # building the site, pages, page templates, partials and assets
    include Geb::Site::Release    # releasing the site, pages and assets
    include Geb::Site::Template   # mostly remote template handling
    include Geb::Site::Remote     # remote site functionality, ssh, scp, rsync, etc.

    # @!attribute [r] site_path
    #  @return [String] the site path
    attr_reader :site_path

    # @!attribute [r] site_config
    # @return [Geb::Config] the site configuration
    attr_reader :site_config

    # @!attribute [r] template_path
    # @return [String] the path template the site is based on
    attr_reader :template_path

    # @!attribute [r] validated
    # @return [Boolean] true if the site is validated
    attr_reader :validated

    # @!attribute [r] loaded
    # @return [Boolean] true if the site is loaded
    attr_reader :loaded

    # @!attribute [r] pages
    # @return [Hash] the site pages to process
    attr_reader :pages

    # site constructor
    # initializes the site object and attributes
    def initialize

      @validated = false
      @loaded = false
      @site_path = nil
      @template_path = nil
      @pages = {}

    end # def initialize

    private

    # get the site name.  It either uses the configured name or the last folder in
    # the site_path as site name.
    # @return [String] the site name
    def site_name
      return  @site_config.site_name
    end # def site_name

  end # class Site

end # module Geb
