# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Build command definition, based on Dry::CLI framework
#  Run a webrick http server to view the site output
#
#  Licence MIT
# -----------------------------------------------------------------------------
module Geb
  module CLI
    module Commands

      # Define server command
      class Server < Dry::CLI::Command

        # Command description, usage and examples
        desc "Start a local server to view the site output (runs build first), uses webrick"
        example [" ", "--port 8080", "--skip_build"]

        # Define command options
        option :port,       type: :int,     default: 3456,  desc: "Port to run the server on, otherwise it will use config file setting"
        option :skip_build, type: :boolean, default: false, desc: "Skip building the site before starting the server"

        # Call method for the server command
        def call(port:, skip_build:)

          puts "Running server"

        end # def call

      end # class Server < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
