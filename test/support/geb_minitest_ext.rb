# frozen_string_literal: true
#
# Minitest extensions for Geb, mostly syntax sugar for tests.
#
# @title Geb - Test Support - Minitest Extensions
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information


# create some syntax sugar for the tests. It turns the default way to define tests as methods,
# into a more readable form.
# @example
#
# class TestSomething < Minitest::Test
#
#   # this is the default way to define a test
#   def test_this_is_a_test
#     assert true
#   end
#
#   # isn't this better, this will be converted to test_this_is_a_test
#   test "this is a test" do
#     assert true
#   end
#
# end
#
class Minitest::Test
  def self.test(description, &block)
    define_method("test_#{description.gsub(/\s+/, '_')}", &block)
  end # def self.test
end # class Minitest::Test
