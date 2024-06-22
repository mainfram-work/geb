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

class TestGebCommandBuild < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Build.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call(skip_assets: false, skip_pages: false)

    assert_stdout_match(/Building pages and assets/)

  end # def test_that_command_default_executes

end # class TestGebCommandBuild < Minitest::Test
