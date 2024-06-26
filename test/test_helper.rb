# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Minitest test helper class.
#
#
#  Licence MIT
# -----------------------------------------------------------------------------
require 'simplecov'
SimpleCov.start do
  command_name 'rake test'
  add_filter '/test/'
end
SimpleCov.at_exit {}

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "geb"
require 'minitest/autorun'
require 'mocha/minitest'
require 'webrick'
require "stringio"

Minitest.after_run { SimpleCov.result.format! }

require_relative 'support/geb_cli_test'
require_relative 'support/geb_api_test'
require_relative 'support/geb_test_helpers'
require_relative 'support/geb_web_server_proxy'

# create some syntax sugar for the tests
class Minitest::Test
  def self.test(description, &block)
    define_method("test_#{description.gsub(/\s+/, '_')}", &block)
  end
end

# ::: Helpers :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
