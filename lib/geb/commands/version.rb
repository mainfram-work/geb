# frozen_string_literal: true
#
# Version command definition, based on Dry::CLI framework
# Prints the current version of the Geb
#
# @title Geb - Version Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  module CLI
    module Commands

      # Define version command
      class Version < Dry::CLI::Command

        # Command description, usage and examples
        desc "Print version"
        example [" "]

        # Call method for the version command
        def call(*)

          # Print the version
          puts "Geb version #{Geb::VERSION}"

        end # def call

      end # class Version < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
