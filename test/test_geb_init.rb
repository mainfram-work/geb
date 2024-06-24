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
    default_template = Geb::CLI::Commands::Init::AVAILABLE_TEMPLATES.first

    @command.call(site_path: "new_site")

    assert_stdout_match("No template specified, using default: #{default_template}.")
    assert_stdout_match("Specified template is a Geb sample: #{default_template}, using it as site template.")

    assert_stdout_match("Creating site folder: #{new_site_path} ... done.")
    assert Dir.exist?(new_site_path), "New site folder should exist after init command"

    assert_stdout_match("Initialising git repository ... done.")
    assert Dir.exist?("#{new_site_path}/.git"), "New site folder should contain a git repository after init command"
    assert File.exist?("#{new_site_path}/.gitignore"), "New site folder should contain a git ignore file after init command"

    assert_stdout_match("Creating: #{File.join(new_site_path, "output")} ... done.")
    assert File.exist?(File.join(new_site_path, "output")), "New site folder should contain an output folder after init command"

    assert_stdout_match("Creating: #{File.join(new_site_path, "output/local")} ... done.")
    assert File.exist?(File.join(new_site_path, "output/local")), "New site folder should contain an output/local folder after init command"

    assert_stdout_match("Creating: #{File.join(new_site_path, "output/release")} ... done.")
    assert File.exist?(File.join(new_site_path, "output/release")), "New site folder should contain an output/release folder after init command"

    assert_stdout_match(/Populating site from template.*#{default_template}/)
    assert_stdout_match(/Site generated from template.*#{default_template}/)

    # No template specified, using default: bootstrap_jquery.
    # Specified template is a Geb sample: bootstrap_jquery, using it as site template.
    # Creating site folder: tmp/foobar2 ... done.
    # Skipping initializing git as told.
    # Creating: tmp/foobar2/output ... done.
    # Creating: tmp/foobar2/output/local ... done.
    # Creating: tmp/foobar2/output/release ... done.
    # Populating site from template: /Users/mainfram/ActionTwelve/Products/geb/geb/lib/geb/samples/bootstrap_jquery, found 10 entries.
    # Creating directory: tmp/foobar2/assets ... done.
    # Creating directory: tmp/foobar2/shared ... done.
    # Creating file: tmp/foobar2/blog/blog_post_1.html ... done.
    # Creating file: tmp/foobar2/blog/blog_post_2.html ... done.
    # Creating file: tmp/foobar2/blog/blog_post_3.html ... done.
    # Creating file: tmp/foobar2/blog/index.html ... done.
    # Creating file: tmp/foobar2/index.html ... done.
    # Creating file: tmp/foobar2/page.html ... done.
    # Creating file: tmp/foobar2/site.webmanifest ... done.
    # Creating file: tmp/foobar2/geb.config.yml ... done.
    # Site generated from template /Users/mainfram/ActionTwelve/Products/geb/geb/lib/geb/samples/bootstrap_jquery.

  end # def test_that_command_default_executes

end # class TestGebCommandInit < Minitest::Test
