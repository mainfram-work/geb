# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  This is a CLI test base class for Geb.  It provides a consistant setup and
#  teardown for CLI tests. Current setup and teardown handle the following
#  tasks:
#  - Creates a temporary directory and changes to it, removes it after the test
#  - Sets up a proxy server if the PROXY_PORT is defined, stops server after the test
#
#  Licence MIT
# -----------------------------------------------------------------------------

module Geb
  class CliTest < Minitest::Test

    PROXY_PORT = 8888

    # Common setup logic
    # redirects stdout and stderr to StringIO
    # creates a temporary directory and changes to it
    def setup

      # setup a temporary directory and change to it
      @temp_dir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@temp_dir)

      # initialize the proxy instance
      @proxy = nil

    end # def setup

    # Common teardown logic
    # redirects stdout and stderr back to their original state
    # changes back to the original directory
    def teardown

      Dir.chdir(@original_dir)
      FileUtils.remove_entry @temp_dir

      # stop the web server if it is defined and running
      @proxy.stop if @proxy && @proxy.running?

    end # def teardown

    # Starts the proxy server if the PROXY_PORT is defined
    def start_proxy

      # start the proxy server only if the PROXY_PORT is defined
      if PROXY_PORT

        # start the web server
        @proxy = Geb::Test::WebServerProxy.new(PROXY_PORT, debug: false)
        @proxy.start

      end # if PROXY_PORT

      # return the proxy instance
      return @proxy

    end # def start_proxy

    # copy the test site into the current directory
    def copy_test_site

        # get the test site path
        test_site_path = File.expand_path(File.join(__dir__, '..', 'files/test-site'))

        # copy the test site contents into the current directory
        FileUtils.cp_r(File.join(test_site_path, '.'), Dir.pwd)

    end # def copy_test_site

  end # class CliTest < Minitest::Test

end # module Geb
