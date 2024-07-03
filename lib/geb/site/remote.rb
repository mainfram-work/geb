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

    end # module Remote
  end # class Site
end # module Geb
