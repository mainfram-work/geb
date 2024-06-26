# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb server command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandServer < Geb::CliTest

  test "that the CLI api call works" do

   command = Geb::CLI::Commands::Server.new

   command_options = { port: 3000, skip_build: false }

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
    stdout, stderr, status = Open3.capture3('geb server')

    # assert that the output contains the expected string
    assert status.success?
    assert_match(/Running server/, stdout)
    assert_empty stderr

  end # test "command line"

end # class TestGebCommandServer < Minitest::Test
