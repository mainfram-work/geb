# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Version command definition, based on Dry::CLI framework
#  Prints the current version of the Geb
#
#  Licence MIT
# -----------------------------------------------------------------------------
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
