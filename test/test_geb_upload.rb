# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb upload command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandUpload < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Upload.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call(skip_build: false, skip_assets_build: false, skip_pages_build: false)

    assert_stdout_match(/Uploading site/)

  end # def test_that_command_default_executes

end # class TestGebCommandUpload < Minitest::Test
