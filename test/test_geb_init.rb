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
require "fileutils"
require "tmpdir"

class TestGebCommandInit < Minitest::Test

  def setup

    # setup a command instance for all test
    @command = Geb::CLI::Commands::Init.new

    # setup a StringIO to capture standard output
    @original_stdout = $stdout
    $stdout = StringIO.new

    # create a temporary test directory
    @temp_dir = Dir.mktmpdir
    @original_dir = Dir.pwd
    Dir.chdir(@temp_dir)

  end # def setup

  def teardown

    # reset $stdout
    $stdout = @original_stdout

    # remove the temporary test directory
    Dir.chdir(@original_dir)
    FileUtils.remove_entry @temp_dir

  end # def teardown

  def test_that_command_default_executes

    new_site_path = "new_site"

    @command.call(site_path: "new_site", skip_config: false, skip_locations: false, skip_assetfolders: false, skip_git: false, skip_index: false, skip_site_manifest: false, skip_snippets: false, skip_js: false, skip_css: false, force: false)

    assert_stdout_match("Creating site folder: #{new_site_path} ... done.")
    assert Dir.exist?(new_site_path), "New site folder should exist after init command"

    assert_stdout_match("Initialising git repository ... done.")
    assert Dir.exist?("#{new_site_path}/.git"), "New site folder should contain a git repository after init command"
    assert File.exist?("#{new_site_path}/.gitignore"), "New site folder should contain a git ignore file after init command"

  end # def test_that_command_default_executes

end # class TestGebCommandInit < Minitest::Test
