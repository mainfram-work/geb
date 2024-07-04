# frozen_string_literal: true
#
# Site remote functionality, things like ssh, scp, rsync, etc.
#
# @title Geb - Site - Remote
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class Site
    module Remote

      class RemoteURINotConfigured < Geb::Error
        MESSAGE = "Remote URI not configured in geb.config.yml".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class RemoteURINotConfigured < Geb::Error

      class RemotePathNotConfigured < Geb::Error
        MESSAGE = "Remote Path is not configured in geb.config.yml".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end # class RemotePathNotConfigured < Geb::Error

      class SiteNotReleasedError < Geb::Error
        MESSAGE = "Site not released. Please run 'geb release' first.".freeze
        def initialize(e = ""); super(e, MESSAGE); end
      end

      # launch a remote session
      # @return [Nil]
      # @raise SiteNotLoadedError if the site is not loaded
      # @raise RemoteURINotConfigured if the remote uri is not configured
      def launch_remote

        # raise an error if the site is not loaded
        raise Geb::Site::SiteNotFoundError.new("Site not loaded") unless @loaded

        # make sure the remote uri is configured
        raise RemoteURINotConfigured.new unless @site_config.remote_uri

        # Temporarily disable reporting exceptions in threads
        original_thread_report_on_exception_setting = Thread.report_on_exception
        Thread.report_on_exception = false

        Geb.log "About to start an ssh session with the remote server #{@site_config.remote_uri}."

        # attempt to launch a remote session
        begin
          Open3.capture3("ssh", @site_config.remote_uri)
        rescue Interrupt, IOError
          Geb.log "Remote session interrupted."
        rescue
          Geb.log "Remote session interrupted."
        ensure
          # restore the original thread report on exception setting
          Thread.report_on_exception = original_thread_report_on_exception_setting
        end # begin ... rescue

      end # def launch_remote

      # upload the site release to the remote server
      # @return [Nil]
      # @raise SiteNotReleasedError if the site has not been released
      # @raise RemoteURINotConfigured if the remote uri is not configured
      # @raise RemotePathNotConfigured if the remote path is not configured
      def upload_release_to_remote()

        # check if the release directory is empty
        raise SiteNotReleasedError.new unless released?

        # make sure the remote uri and remote path are configured
        raise RemoteURINotConfigured.new  unless @site_config.remote_uri
        raise RemotePathNotConfigured.new unless @site_config.remote_path

        # Temporarily disable reporting exceptions in threads
        original_thread_report_on_exception_setting = Thread.report_on_exception
        Thread.report_on_exception = false


        Geb.log "About to upload the site release to remote server2."

        # attempt to upload the release to the remote server
        begin

          # build up the command arguments
          command_exclude_pattern = '*.DS_Store'
          command_source_directory  = File.join(get_site_release_output_directory(), '/')
          command_remote_uri        = @site_config.remote_uri + ":" + @site_config.remote_path

          # build the rsync command
          rsync_command = [
            'rsync',
            '-av',
            '-e', 'ssh',
            "--exclude=#{command_exclude_pattern}",
            command_source_directory,
            command_remote_uri
          ]

          Geb.log " - upload command: #{rsync_command.join(' ')}"

          # execute the rsync command
          Open3.popen3(*rsync_command) do |stdin, stdout, stderr, wait_thr|

            # create threads to read the stdout
            stdout_thread = Thread.new do
              stdout.each_line { |line| Geb.log " - #{line}" }
            end

            # create threads to read the stderr
            stderr_thread = Thread.new do
              stderr.each_line { |line| Geb.log " - (error) #{line}" }
            end

            # wait for the threads to finish
            stdout_thread.join
            stderr_thread.join

            # get the status of the command
            status = wait_thr.value

            # log the status of the command
            { stdout: stdout, stderr: stderr, status: status }

          end # Open3.popen3

        rescue Interrupt, IOError
          Geb.log "Upload interrupted."
        rescue
          Geb.log "Upload interrupted."
        ensure
          # restore the original thread report on exception setting
          Thread.report_on_exception = original_thread_report_on_exception_setting
        end # begin ... rescue

      end # def upload_release_to_remote

    end # module Remote
  end # class Site
end # module Geb
