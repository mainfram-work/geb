# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Minitest extensions for Geb, mostly syntax sugar for tests.
#
#  Licence MIT
# -----------------------------------------------------------------------------


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
