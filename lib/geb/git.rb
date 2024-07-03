# frozen_string_literal: true
#
# Simple set of git utilities used by the cli commands
#
# @title Geb - Git
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# include the required libraries
require 'tmpdir'
require 'open3'
require 'shellwords'

module Geb
  module Git

    class FailedValidationError < Geb::Error
      MESSAGE = "Could not evaluate if the specified SITE_PATH is within a git repository, please choose a different location or use the --skip_git option.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class FailedValidationError < Geb::Error

    class InsideGitRepoError < Geb::Error
      MESSAGE = "You are already inside a git repository, please choose a different location or use the --skip_git option.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class InsideGitRepoError < Geb::Error

    class GitError < Geb::Error
      MESSAGE = "An error occurred while executing a git command.".freeze
      def initialize(e = ""); super(e, MESSAGE); end
    end # class GitError < Geb

    # ::: Class Methods ::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    # validate if the proposed directory is a git repository, raise an error if it is
    # or if the directory is inside a git repository
    # @param site_directory [String] the proposed site directory
    # @raise [FailedValidationError] if the directory could not be evaluated
    # @raise [InsideGitRepoError] if the directory is inside a git repository
    # @raise [GitError] if an error occurred while executing the git command
    # @return [void]
    def self.validate_git_repo(site_directory)

      Geb.log_start "Validating proposed site path as a git repository ... "

      # initialize the closest directory to the site directory that actually exists
      closest_existing_directory = site_directory


      # find the closest existing directory
      until Dir.exist?(closest_existing_directory)
        closest_existing_directory = File.dirname(closest_existing_directory)
      end # until

      # raise an error if we reached the root directory
      raise FailedValidationError if closest_existing_directory == '/'

      # perform the git check in the closest existing directory
      _, stderr, status = Open3.capture3("cd #{Shellwords.shellescape(closest_existing_directory)} && git rev-parse --is-inside-work-tree")

      # check if the error message is that the directory is not in a git repository
      raise InsideGitRepoError if status.success?

      # the above git command will fail if the directory is not in a git repository (we want that)
      # raise error for all other errors
      raise FailedValidationError.new(stderr.chomp) unless stderr.include?("not a git repository")

      Geb.log "done."

    end # def self.validate_git_repo(site_directory)

    # Create a new git repository in the specified folder. It also creates a .gitignore file
    # @param site_directory [String] the proposed site directory
    # @raise [GitError] if an error occurred while executing the git command
    # @return [void]
    def self.create_git_repo(site_directory)

      Geb.log_start "Initialising git repository ... "

      # initialize the git repository
      _, stderr, status = Open3.capture3("git -C #{Shellwords.shellescape(site_directory)} init")

      # raise an error if the git command failed
      raise GitError.new(stderr.chomp) unless status.success?

      # attempt to create a .gitignore file
      begin

        # create a .gitignore file
        File.open(File.join(site_directory, '.gitignore'), 'w') do |f|

          # ignore everything withint the output folder
          f.puts "/output"
          f.puts "/.DS_Store"

        end # File.open

      rescue StandardError => e

        # raise an error if the gitignore file could not be created
        raise GitError.new("Could not create .gitignore file: #{e.message}")

      end # begin ... rescue

      Geb.log "done."

    end # def self.create_git_repo

  end # module Git
end # module Geb
