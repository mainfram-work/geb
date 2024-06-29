# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  The http server class. This class is used to run a simple http server
#  for the Geb gem.  It also contains the file monitoring code to automatically.
#  build the site when a file changes.
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include the required libraries
require 'webrick'
require 'listen'

module Geb
  class Server

    # initialise the http server class with the site and port, use auto_build to start the file watcher.
    # @param site [Geb::Site] the site instance to serve
    # @param port [Integer] the port to run the server on
    # @param auto_build [Boolean] whether to start the file watcher
    def initialize(site, port, auto_build)

      # set the site and port
      @site = site
      @port = port

      # get the http server instance and file watcher if auto_build is set
      @http_server  = get_http_server()
      @file_watcher = auto_build ? get_file_watcher() : nil

      # initialize the http server and file watcher threads
      @http_server_thread  = nil
      @file_watcher_thread = nil

    end # def initialize

    # start the http server and file watcher
    def start

      # start the http server in its own thread
      @http_server_thread  = Thread.new { @http_server.start }

      # start the file watcher if it is set in its own thread
      @file_watcher_thread = @file_watcher ? Thread.new { @file_watcher.start } : nil

    end # def start

    # stop the http server and file watcher
    def stop

      # shutdown the http server
      Geb.log "Shutting down http server."
      @http_server.shutdown
      @http_server_thread.join

      # shutdown the file watcher
      Geb.log "Shutting down file watcher."  if @file_watcher
      @file_watcher.stop                     if @file_watcher
      @file_watcher_thread.join              if @file_watcher_thread

    end # def stop

    private

    # Get an instance of the http server
    # @return [WEBrick::HTTPServer] the http server instance
    def get_http_server

      # Create a new WEBrick server
      server = WEBrick::HTTPServer.new(
        Port: @port,
        DocumentRoot: @site.get_site_output_directory()
      ) # WEBrick::HTTPServer.new

      Geb.log "Server running on http://localhost:#{@port}"

      # return the http server
      return server

    end # get an instance of the http server

    # Get an instance of the file watcher
    # @return [Listen] the file watcher instance
    # @note the file watcher will ignore the output and release directories
    # @note the file watcher will attempt to rebuild the site when a file changes
    # @note the file watcher will log any errors to the console, but will not stop watching
    def get_file_watcher()

      # create a new file watcher and define the block to run when a file changes
      watcher = Listen.to(@site.site_path) do |modified, added, removed|

        # check if any files have been modified, added or removed
        if modified.any? || added.any? || removed.any?

          Geb.log "Modified files detected: #{modified}" if modified.any?
          Geb.log "New files detected: #{added}"         if added.any?
          Geb.log "File removal detected: #{removed}"    if removed.any?
          Geb.log_start "Found changes, rebuilding site ... "

          # attempt to rebuild the site, log any errors but do not stop watching
          begin

            # rebuild the site, suppress log output
            Geb.no_log { @site.build() }

          rescue Geb::Error => e
            Geb.log "\nError rebuilding site: #{e.message}"
          end # begin rescue

          Geb.log "done."

        end # if

      end # Listen.to(site.site_path) do |modified, added, removed|

      # set ignore the output and release directories, cleanup the paths and make them relative to the site path
      ignore_output_dir   = @site.get_site_output_directory().gsub(@site.site_path, '').gsub(/\A\W+/, '')
      ignore_release_dir  = @site.get_site_release_directory().gsub(@site.site_path, '').gsub(/\A\W+/, '')

      Geb.log  "Watching for changes in [#{@site.site_path}]"
      Geb.log  "Ignoring [#{ignore_output_dir}]"
      Geb.log  "Ignoring [#{ignore_release_dir}]"

      # ignore the output directory and the release directory
      watcher.ignore(%r{^#{Regexp.escape(ignore_output_dir)}})
      watcher.ignore(%r{^#{Regexp.escape(ignore_release_dir)}})

      # return the file watcher
      return watcher

    end # def get_file_watcher

  end # class Server
end # module Geb
