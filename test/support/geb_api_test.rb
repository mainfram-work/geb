# frozen_string_literal: true
#
# This is a Api test base class for Geb.  It provides a consistant setup and
# teardown for API tests. Currently just stubs the Geb::log and Geb::log_start
# as not to polute the test output with logging.
#
# @title Geb - Test Support - API Test
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class ApiTest < Minitest::Test

    # Common setup logic
    # redirects stdout and stderr to StringIO
    # creates a temporary directory and changes to it
    def setup

      # suppress Geb logger output
      Geb.stubs(:log)
      Geb.stubs(:log_start)

    end # def setup

    # Common teardown logic
    # redirects stdout and stderr back to their original state
    # changes back to the original directory
    def teardown

    end # def teardown

  end # class CliTest < Minitest::Test

end # module Geb
