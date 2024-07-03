# frozen_string_literal: true
#
# Tests the upload command class
#
# @title Geb - Test - Upload Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestGebCommandUpload < Geb::CliTest

  test "that the CLI api call works" do

    copy_test_site()

    command = Geb::CLI::Commands::Upload.new

    command_options = { }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    Open3.expects(:popen3).returns(["", "", ""])

    command.call(**command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that the Open3 block executes correctly" do

    copy_test_site()

    command = Geb::CLI::Commands::Upload.new

    command_options = { }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    mock_stdout = StringIO.new("mocked stdout line 1\nmocked stdout line 2\n")
    mock_stderr = StringIO.new("mocked stderr line 1\nmocked stderr line 2\n")
    mock_wait_thr = mock('wait_thr')
    mock_wait_thr.stubs(:value) #.returns(mock('status', exitstatus: 0))

    Open3.stubs(:popen3).yields(nil, mock_stdout, mock_stderr, mock_wait_thr)

    command.call(**command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the Open3 block executes correctly"

  test "that the command executes correctly with exception" do

    copy_test_site()

    command = Geb::CLI::Commands::Upload.new

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

  end # test "that the command executes correctly with exception"

end # class TestGebCommandUpload < Minitest::Test
