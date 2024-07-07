# frozen_string_literal: true
#
# A web server (using Webrick) that proxies requests. Allows tests to stub
# requests and responses. Useful for testing HTTP requests.
#
# @title Geb - Test Support - Test Helpers
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information


require "webrick"

module Geb
  module Test

    # NullLogger class, used to suppress logging for the Webrick server
    class NullLogger
      def method_missing(*args)
        # Do nothing
      end
    end

    # WebServerProxy class, used to create a web server that proxies requests
    class WebServerProxy

      # find an available port
      # @return [Integer] the available port
      def self.find_available_port

        # start a new server and get the port
        server = TCPServer.new(0)
        port = server.addr[1]

        # close the server
        server.close

        # return the port
        return port

      end # def self.find_available_port

      # initialize the server, takes a port and a debug flag that stops the server will log to STDOUT
      # @param port [Integer] the port the server will run on
      # @param debug [Boolean] if true, the server will log to STDOUT
      # @return [WebServerProxy] the server instance
      def initialize(port, debug: false)

        # start the server, consider debug flag
        if debug
          @server = WEBrick::HTTPServer.new(Port: port, AccessLog: [[STDOUT, WEBrick::AccessLog::COMMON_LOG_FORMAT], [STDOUT, WEBrick::AccessLog::REFERER_LOG_FORMAT]])
        else
          @server = WEBrick::HTTPServer.new(Port: port, Logger: NullLogger.new, AccessLog: [] )
        end # if else

        # mount the server root, just so we have something to return
        @server.mount_proc("/") do |req, res|
          res.body = "This server is for geb testing."
          res.status = 200
          res["Content-Type"] = "text/plain"
        end # mount_proc

      end # def initialize

      # start the server
      def start
        @thread = Thread.new do
          @server.start
        end
      end # def start

      # stop the server
      def stop
        @server.shutdown if @server
        @thread.join if @thread
      end # def stop

      # check if the server is running
      def running?
        @thread&.alive?
      end # def running?

      # get the base url of the server
      def base_url
        return "http://localhost:#{@server.config[:Port]}"
      end # def base_url

      # stub a request, this is the whole point of this class
      # @param url [String] the url to stub
      # @param headers [Hash] the headers to return
      # @param body [String] the body to return (optional)
      # @param block [Block] a block to call to return the body (optional)
      # @return [void]
      # @example
      #
      #   # stub a simple request
      #   http_proxy = start_proxy
      #   http_proxy.stub_request("http://example.com", { 'Content-Type' => 'text/html' }, "<html></html>")
      #
      #   # stub a request with a block
      #   http_proxy.stub_request("http://example.com", { 'Content-Type' => 'text/html' }) do
      #     "<html></html>"
      #   end
      #
      def stub_request(url, headers = {}, body = nil, &block)

        # strip the base_url from url
        url = url.gsub(base_url, "")

        # mount the request, url, headers, body and block
        @server.mount_proc(url) do |request, response|

          # set the response headers to the headers passed in
          headers.each { |k, v| response[k] = v }

          # set the response body to the body passed in or the block
          response.body = block_given? ? block.call : body

        end # mount_proc

      end # def stub_request

    end # class WebServerProxy

  end # module Test
end # module Geb
