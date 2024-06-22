# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb version command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandVersion < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Version.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call

    assert_stdout_match(/Geb version #{Geb::VERSION}/)

  end # def test_that_command_default_executes

end # class TestGebCommandVersion < Minitest::Test
