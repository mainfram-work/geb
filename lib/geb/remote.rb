# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Remote command definition, based on Dry::CLI framework
#  Simply call ssh using the configured remote string, convinience command
#
#  Licence MIT
# -----------------------------------------------------------------------------
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
