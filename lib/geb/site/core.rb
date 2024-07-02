# frozen_string_literal: true
#
# Site core functionality, loading, validation and creation
#
# @title Geb - Site - Core Module
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class Site
    module Core

      class DirectoryExistsError < Geb::Error
        MESSAGE = "Site folder already exists, please choose a different name or location.\nIf you want to use the existing site folder, use the --force option.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class DirectoryExistsError < Geb::Error

      class SiteAlreadyValidated < Geb::Error
        MESSAGE = "Proposed site and template have not been validated. This is an internal error".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class SiteAlreadyValidated < Geb::Error

      class InvalidTemplate < Geb::Error
        MESSAGE = "Invalid template site. Make sure the specified path is a directory and contains a valid geb.config.yml file.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class InvalidTemplate < Geb::Error

      class UnvalidatedSiteAndTemplate < Geb::Error
        MESSAGE = "You are trying to create an unvalidated site. This is an internal error".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class UnvalidatedSiteAndTemplate < Geb::Error

      class SiteNotFoundError < Geb::Error
        MESSAGE = "Could not find geb config file.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class SiteNotFoundError < Geb::Error

      # validate the site path and template path, and set the validated flag
      # it executes the following validations:
      #   - make sure the site is not already validated
      #   - make sure the site path is valid, consider force option
      #   - if template path is nil, use the default template
      #   - if template path is a URL, validate the URL and download the template
      #   - if template path is a directory, check if it has a geb.config.yml file
      # @param site_path      [String]  the path to the site folder
      # @param template_path  [String]  the path to the site template, default is nil, can be a URL, directory or a bundled template identifier
      # @param skip_template  [Boolean] skip the template validation, default is false
      # @param force          [Boolean] force the site creation, default is false
      # @raise SiteAlreadyValidated if the site has already been validated
      # @raise DirectoryExistsError if the site folder already exists and force option is not set
      # @raise InvalidTemplate if the template path is invalid
      # @raise InvalidTemplateURL if the template URL is invalid
      # @return [Nil]
      def validate(site_path, template_path = nil, skip_template = false, force = false)

        # raise an error if the site has already been validated
        raise SiteAlreadyValidated.new if @validated

        Geb.log_start "Validating site path #{site_path} ... "
        # raise error if site folder already exists and force option is not set
        raise DirectoryExistsError.new if site_directory_exists?(site_path) && !force
        @site_path = site_path
        Geb.log('done.')

        Geb.log("Skipping template validation as told.") if skip_template

        # check if we are skipping the template
        unless skip_template

          # initialize the template directory path.
          template_dir = nil

          # if the template path is nil, use the first bundled template name
          if template_path.nil? || template_path.empty?

            Geb.log "No template specified, using default: #{Geb::Defaults::DEFAULT_TEMPLATE}."
            template_dir = Geb::Defaults::DEFAULT_TEMPLATE_DIR

          end # if

          # check if the template path is a URL
          if is_url?(template_path) && template_dir.nil?

            # check if the template URL is valid and download it if it is
            valid_template_url = validate_template_url(template_path)
            template_dir       = download_template_from_url(valid_template_url)

          end # if

          # check if the template path is a bundled template
          if template_dir.nil? && is_bundled_template?(template_path)

            template_dir = File.join(Geb::Defaults::BUNDLED_TEMPLATES_DIR, template_path)
            Geb.log "Specified template is a Geb sample: #{template_path}, using it as site template."

          end # if

          # set the template dir to specified template path if template dir is still nil
          template_dir = template_path if template_dir.nil? # this is the case when the template is a local directory

          # check if the template path is a directory and ontains a geb.config.yml file
          Geb.log_start "Validating template path #{template_dir.to_s} ... "
          raise InvalidTemplate.new if template_dir.nil?
          raise InvalidTemplate.new unless template_directory_exists?(template_dir)
          raise InvalidTemplate.new unless Geb::Config.site_directory_has_config?(template_dir)
          Geb.log "done."

          # set the template path
          @template_path = template_dir

        end # unless skip_template

        # set the validated flag
        @validated = true

      end # def validate

      # create the site. It assumes and checks that the site has been validated first.
      # the reason we don't just call validate from here is that we want to separate
      # the validation from the creation for CLI UI purposes.
      # performs the following steps
      #   - raise an error if the site has not been validated
      #   - create the site folder, if it exists, just skip it
      #   - copy the template files to the site folder if the template path is set
      #   - create the output folders
      # @raise UnvalidatedSiteAndTemplate if the site has not been validated
      # @return [Nil]
      def create

        # raise an error if the site has not been validated
        raise UnvalidatedSiteAndTemplate.new unless @validated

        # check if the folder already exists, if we are here and it does, just skip it, validation would have considered a force option
        Geb.log_start "Creating site folder: #{@site_path} ... "
        if site_directory_exists?(@site_path)
          Geb.log "skipped, folder already exists."
        else
          Dir.mkdir(@site_path)
          Geb.log "done."
        end # if

        Geb.log("Skipping template creation as told.") if @template_path.nil?

        # check if we are skipping the template, if not copy the template files
        copy_template_from_path unless @template_path.nil?

        # check if the site has a geb config file, if not, copy the default one
        if Geb::Config.site_directory_has_config?(@site_path)
          Geb.log "Config file already exists, no need to create it."
        else
          Geb.log_start "Creating default geb config file ... "
          FileUtils.cp(File.join(Geb::Defaults::BUNDLED_TEMPLATES_DIR, Geb::Defaults::SITE_CONFIG_FILENAME), @site_path)
          Geb.log "done."
        end # if else

        # load the site config
        @site_config = Geb::Config.new(self)

        # create the assets folder if it does not exist
        if File.directory?(File.join(@site_path, @site_config.assets_dir))
          Geb.log "Assets folder already exists, no need to create it."
        else
          Geb.log_start "Creating assets folder since it wasn't created by the template ... "
          FileUtils.mkdir_p(File.join(@site_path, @site_config.assets_dir))
          Geb.log "done."
        end # if else

        # create the output folders
        Geb.log_start "Creating: local and release output folders ..."
        FileUtils.mkdir_p(File.join(@site_path, @site_config.output_dir, Geb::Defaults::LOCAL_OUTPUT_DIR))
        FileUtils.mkdir_p(File.join(@site_path, @site_config.output_dir, Geb::Defaults::RELEASE_OUTPUT_DIR))
        Geb.log "done."

      end # def create

      # load a site from a site path
      # it checks if the site path has a geb config file, if not, it goes up the chain to find it
      # @param site_path [String] the path to the site folder
      # @raise SiteNotFoundError if the site path is not found
      # @return [Nil]
      def load(site_path)

        Geb.log_start "Loading site from path #{site_path} ... "

        # set the site path candidate
        site_path_candidate = site_path

        # check if the site has a geb config file, if not go up the chain to find it
        until site_path_candidate == '/'

          # check if the site path has a geb config file
          if Geb::Config.site_directory_has_config?(site_path_candidate)

            # set the site path
            @site_path = site_path_candidate

            # load the site configuration
            @site_config = Geb::Config.new(self)

            # set the loaded flag and break the loop
            @loaded = true
            break

          end # if

          # go up the chain
          site_path_candidate = File.expand_path('..', site_path_candidate)

        end # until

        # raise an error if the site path is not found
        raise SiteNotFoundError.new("#{site_path} is not and is not in a geb site.") unless @loaded

        Geb.log "done."
        Geb.log "Found geb site at path #{@site_path} as #{site_name}."

      end # def load

      # check if the site directory exists
      def site_directory_exists?(site_path)
        File.directory?(site_path)
      end # def site_directory_exists?

    end
  end
end
