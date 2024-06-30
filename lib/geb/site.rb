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

module Geb
  class Site

    # include site sub-modules
    include Geb::Site::Core       # core site functionality, loading, validation and creation
    include Geb::Site::Template   # mostly remote template handling
    include Geb::Site::Build      # building the site, pages, page templates, partials and assets
    include Geb::Site::Release    # releasing the site, pages and assets

    # attribute readers
    attr_reader :site_path, :template_path, :validated, :loaded, :pages

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

    # get the last folder in the site_path as site name
    def site_name
      return File.basename(@site_path)
    end # def site_name

  end # class Site

end # module Geb
