# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb build command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandBuild < Geb::CliTest

  test "that the CLI api call works" do

    copy_test_site()

    command = Geb::CLI::Commands::Build.new

    command_options = { skip_assets: false, skip_pages: false }

    site_mock = mock('site')
    site_mock.expects(:load).with(Dir.pwd)
    site_mock.expects(:build_assets)
    site_mock.expects(:build_pages)

    Geb::Site.expects(:new).returns(site_mock)

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(**command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that the CLI api call works with skip_assets and skip_pages" do

    copy_test_site()

    command = Geb::CLI::Commands::Build.new

    command_options = { skip_assets: true, skip_pages: true }

    site_mock = mock('site')
    site_mock.expects(:load).with(Dir.pwd)
    site_mock.expects(:build_assets).never
    site_mock.expects(:build_pages).never

    Geb::Site.expects(:new).returns(site_mock)

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(**command_options)

    assert_empty $stderr.string

    assert_match(/Skipping building assets as told/, $stdout.string)
    assert_match(/Skipping building pages as told/, $stdout.string)

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works with skip_assets and skip_pages"

  test "that the CLI api call works and handles exceptions" do

    # initialize new command instance
    command = Geb::CLI::Commands::Build.new

    command_options = { skip_assets: false, skip_pages: false }

    Geb::Site.expects(:new).raises(Geb::Error.new("Test Error"))

    # setup a StringIO to capture standard output and error
    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(**command_options)

    refute_empty $stderr.string
    assert_match(/Test Error/, $stderr.string)

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works and handles exceptions"

  test "that command default executes" do

    copy_test_site()

    # call geb auto command and capture output and error
    _, stderr, status = Open3.capture3('geb build')

    # assert that the output contains the expected string
    assert status.success?
    assert_empty stderr

  end # test "command line"

end # class TestGebCommandBuild < Minitest::Test
