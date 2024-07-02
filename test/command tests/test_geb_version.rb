# frozen_string_literal: true
#
# Tests the version command class
#
# @title Geb - Test - Version Command
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestGebCommandVersion < Geb::CliTest

  test "that the CLI api call works" do

    command = Geb::CLI::Commands::Version.new

    command_options = {  }

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
    stdout, stderr, status = Open3.capture3('geb version')

    # assert that the output contains the expected string
    assert status.success?
    assert_includes stdout, "Geb version #{Geb::VERSION}"
    assert_empty stderr

  end # test "command line"

  test "that Geb version specified in Geb module and gemspec are the same" do

    gemspec_path = File.expand_path('../../../geb.gemspec', __FILE__)
    @gemspec = Gem::Specification.load(gemspec_path)

    assert_equal @gemspec.version.to_s, Geb::VERSION

  end

end # class TestGebCommandVersion < Minitest::Test
