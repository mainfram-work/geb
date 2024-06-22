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

class TestGebCommandServer < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Server.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call(port: 3456, skip_build: false)

    assert_stdout_match(/Running server/)

  end # def test_that_command_default_executes

end # class TestGebCommandServer < Minitest::Test
