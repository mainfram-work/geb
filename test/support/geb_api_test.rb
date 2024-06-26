# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  This is a CLI test base class for Geb.  It provides a consistant setup and
#  teardown for CLI tests.
#
#  Licence MIT
# -----------------------------------------------------------------------------

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
