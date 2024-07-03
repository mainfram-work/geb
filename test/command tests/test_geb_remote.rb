# frozen_string_literal: true
#
# Tests the remote command class
#
# @title Geb - Test - Remote Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestGebCommandRemote < Geb::CliTest

  test "that the CLI api call works" do

    copy_test_site()

    command = Geb::CLI::Commands::Remote.new

    command_options = { }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    Open3.expects(:capture3).with("ssh", "user@server.com").returns(["", "", ""])

    command.call(**command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that the CLI api call works with an error" do

    copy_test_site()

    command = Geb::CLI::Commands::Remote.new

    command_options = { }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    Geb::Site.expects(:new).raises(Geb::Error.new("Site not loaded"))

    command.call(**command_options)

    assert_match(/Site not loaded/, $stderr.string)

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works with an error"

end # class TestGebCommandRemote < Minitest::Test
