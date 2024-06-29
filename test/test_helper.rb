# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Minitest test helper class. This is where all global test setup is done.
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include seth first... hang on to your hats
require 'seth'

# include simplecov for code coverage
require 'simplecov'

# start simplecov and configure it, before any important code is loaded
SimpleCov.start do
  command_name 'rake test'
  add_filter '/test/'
end # SimpleCov.start

# make sure simplecov runs at the end of the tests
SimpleCov.at_exit {}

# add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# change default encoding to UTF-8, this is important for the tests, as we are
# testing the output of the CLI commands. This is a global setting, so we need
# to suppress warnings with the help of the Seth module.
Seth.suppress_warnings do
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# include the required libraries, including geb, the main code we are testing
require "geb"
require 'minitest/autorun'
require 'mocha/minitest'
require 'webrick'
require "stringio"

# make sure code coverage actually generates a report
# apparently this is not required, but I couldn't get simplecov to work without it
Minitest.after_run { SimpleCov.result.format! }

# include the support files for our tests
require_relative 'support/geb_minitest_ext'         # minitest extensions and syntax sugar
require_relative 'support/geb_cli_test'             # CLI test base class
require_relative 'support/geb_api_test'             # API test base class
require_relative 'support/geb_test_helpers'         # test helper methods
require_relative 'support/geb_web_server_proxy'     # web server proxy for testing
