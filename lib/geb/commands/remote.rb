# frozen_string_literal: true
#
# Remote command definition, based on Dry::CLI framework
# Just a proxy for the ssh command
#
# @title Geb - Remote Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define remote command
      class Remote < Dry::CLI::Command

        # Command description, usage and examples
        desc "Launch remote ssh session using the config file settings"
        example [" "]

        # Define command options

        # Call method for the remote command
        def call(*)

          puts "Running remote"

        end # def call

      end # class Remote < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
