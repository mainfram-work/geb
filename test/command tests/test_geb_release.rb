# frozen_string_literal: true
#
# Tests the release command class
#
# @title Geb - Test - Release Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestGebCommandRelease < Geb::CliTest

  test "that the CLI api call works" do

    copy_test_site()

    command = Geb::CLI::Commands::Release.new

    command_options = { with_template: false }

    site_mock = mock('site')
    site_mock.expects(:load).with(Dir.pwd)
    site_mock.expects(:release)

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

  test "that the CLI api call works and handles exceptions" do

    # initialize new command instance
    command = Geb::CLI::Commands::Release.new

    command_options = { with_template: false }

    Geb::Site.expects(:new).raises(Geb::Error.new("Test Error"))

    # setup a StringIO to capture standard output and error
    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(**command_options)

    refute_empty $stderr.string
    assert_includes $stderr.string, "Test Error"

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works and handles exceptions"

  test "that command default executes" do

    copy_test_site()

    # call geb auto command and capture output and error
    _, stderr, status = Open3.capture3('geb release')

    # assert that the output contains the expected string
    assert status.success?
    assert_empty stderr

  end # test "command line"

  test "that command handles being executed in a non-site directory" do

    # create a temporary directory
    Dir.mktmpdir do |dir|

      # change the current directory to the temporary directory
      Dir.chdir(dir)

      # call geb auto command and capture output and error
      _, stderr, status = Open3.capture3('geb release')

      # assert that the output contains the expected string
      assert status.success?
      refute_empty stderr

    end # Dir.mktmpdir

  end # test "that command handles being executed in a non-site directory"

  test "that the command actually builds and releases the site" do

    copy_test_site()

    stdout, stderr, status = Open3.capture3('geb release')

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Loading site from path #{Dir.pwd} ... done."
    assert_includes stdout, "Found geb site at path #{Dir.pwd}"
    assert_match(/Building \d* pages for/, stdout)
    assert_includes stdout, "loading page"
    assert_includes stdout, "loading template"
    assert_includes stdout, "loading partial"
    assert_includes stdout, "building page"
    assert_match(/Done building \d* pages for/, stdout)
    assert_includes stdout, "Clearing site output folder"
    assert_includes stdout, "Outputting site to"
    assert_includes stdout, "Building assets for"
    assert_includes stdout, "Done building assets for"
    assert_includes stdout, "Clearing site release folder"
    assert_includes stdout, "Releasing site to"

  end # test "that the command actually builds the site"

end # class TestGebCommandRelease < Minitest::Test
