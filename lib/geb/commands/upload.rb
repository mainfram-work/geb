# frozen_string_literal: true
#
# Upload command definition, based on Dry::CLI framework
# Upload the site to a remote server
#
# @title Geb - Upload Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define upload command
      class Upload < Dry::CLI::Command

        # Command description, usage and examples
        desc "Upload the site to the remote server"
        example [" "]

        # Define command options

        # Call method for the remote command
        def call(*)

          # initialize a new site and load the site from the current directory
          site = Geb::Site.new
          site.load(Dir.pwd)

          # check if the site has been released before uploading
          site.upload_release_to_remote()

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message

        end # def call

      end # class Upload < Dry::CLI::Upload

    end # module Commands
  end # module CLI
end # module Geb
