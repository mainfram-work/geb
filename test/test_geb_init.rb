# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the Geb init command
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TestGebCommandInit < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Init.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

  end # def teardown

  def test_that_command_default_executes

    @command.call(skip_config: false, skip_locations: false, skip_assetfolders: false, skip_git: false, skip_index: false, skip_site_manifest: false, skip_snippets: false, skip_js: false, skip_css: false, force: false)

    assert_stdout_match(/Initializing Geb project/)

  end # def test_that_command_default_executes

end # class TestGebCommandInit < Minitest::Test
