# frozen_string_literal: true
#
# Build command definition, based on Dry::CLI framework
# Run a webrick http server to view the site output, it optionally monitors
# for file changes and rebuilds the site when a file changes.
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

      # Define server command
      class Server < Dry::CLI::Command

        # Command description, usage and examples
        desc "Start a local server to view the site output (runs build first), uses webrick"
        example [" ", "--port 8080", "--skip_auto_build", "--skip_build"]

        # Define command options
        option :port,             type: :int,     default: nil,   desc: "Port to run the server on, otherwise it will use config file setting"
        option :skip_build,       type: :boolean, default: false, desc: "Skip building the site before starting the server"
        option :skip_auto_build,  type: :boolean, default: false, desc: "Don't automatically rebuild the site when a file changes"
        option :debug,            type: :boolean, default: false, desc: "Enable full output during site rebuild"

        # Call method for the server command
        # @param options [Hash] the options hash for the command
        def call(**options)

          # initialise a site and load it from the current directory
          site = Geb::Site.new
          site.load(Dir.pwd)

          # build the site if the skip_build option is not set
          site.build() unless options[:skip_build]

          # start a new queue for the shutdown signal (instead of using trap to shutdown the server and file watcher directly)
          @shutdown_queue = Queue.new
          trap('INT') { @shutdown_queue << :shutdown }

          # get the server port from the options, site configuration or auto generated (0), in that order
          server_port = options[:port] || site.site_config.local_port || 0

          # initialize the server
          server = Geb::Server.new(site, server_port, !options[:skip_auto_build], options[:debug])

          # start the server
          server.start()

          # wait for the shutdown signal
          @shutdown_queue.pop

          # stop the server
          server.stop()

        rescue Geb::Error => e

          # print error message
          puts
          warn e.message

        end # def call

        # Force shutdown of the server
        def force_shutdown
          @shutdown_queue << :shutdown if @shutdown_queue
        end # force_shutdown

      end # class Server < Dry::CLI::Command

    end # module Commands
  end # module CLI
end # module Geb
