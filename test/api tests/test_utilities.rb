# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the utilities class
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class UtilitiesTest < Minitest::Test

  test "that Geb error raises a correct error message" do

    # assert that the error message is correct
    error = assert_raises(Geb::Error) do
      raise Geb::Error.new("Custom Error", "Default Message")
    end # assert_raises(Geb::Error)

    assert_equal("Custom Error Default Message", error.message)

  end # test "that Geb error raises a correct error message"

  test "that log prints a message to the console and has a trailing newline" do

      # setup a StringIO to capture standard output
      original_stdout = $stdout
      $stdout = StringIO.new

      # call the log method
      Geb.log("Test Message")

      # assert that the message is correct
      assert_equal("Test Message\n", $stdout.string)

      # reset $stdout
      $stdout = original_stdout

  end # test "that log prints a message to the console and has a trailing newline"

  test "that log_start prints a message to the console and does not have a trailing newline" do

      # setup a StringIO to capture standard output
      original_stdout = $stdout
      $stdout = StringIO.new

      # call the log method
      Geb.log_start("Test Message")

      # assert that the message is correct
      assert_equal("Test Message", $stdout.string)

      # reset $stdout
      $stdout = original_stdout

  end # test "that log_start prints a message to the console and does not have a trailing newline"

  test "that logging can be suppressed" do

    # setup a StringIO to capture standard output
    original_stdout = $stdout
    $stdout = StringIO.new

    Geb.no_log do
      Geb.log("Test Message")
    end

    assert_equal("", $stdout.string)

    Geb.log("Test Message2")

    assert_equal("Test Message2\n", $stdout.string)

    # reset $stdout
    $stdout = original_stdout

  end

end # class UtilitiesTest < Geb::ApiTest
