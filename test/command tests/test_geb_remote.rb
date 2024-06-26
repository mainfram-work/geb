# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb remote command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandRemote < Geb::CliTest

  test "that the CLI api call works" do

   command = Geb::CLI::Commands::Remote.new

   command_options = { }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(**command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that command default executes" do

    # call geb auto command and capture output and error
    stdout, stderr, status = Open3.capture3('geb remote')

    # assert that the output contains the expected string
    assert status.success?
    assert_match(/Running remote/, stdout)
    assert_empty stderr

  end # test "command line"

end # class TestGebCommandRemote < Minitest::Test
