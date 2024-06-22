# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb auto command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandAuto < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Auto.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call(skip_assets_build: false, skip_pages_build: false)

    assert_stdout_match(/Auto Building Site/)

  end # def test_that_command_default_executes

end # class TestGebCommandAuto < Minitest::Test
