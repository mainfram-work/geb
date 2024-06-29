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
require 'webmock/minitest'

class TestGebCommandInit < Geb::CliTest

  test "that the CLI api call works" do

    # initialize new command instance
    command = Geb::CLI::Commands::Init.new

    site_path = "path/to/site"
    command_options = { template: "default", skip_template: false, skip_git: false, force: false }

    site_mock = mock('site')
    site_mock.expects(:validate)
    site_mock.expects(:create)

    Geb::Site.expects(:new).returns(site_mock)
    Geb::Git.expects(:validate_git_repo)
    Geb::Git.expects(:create_git_repo)

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(site_path: site_path, **command_options)

    assert_empty $stderr.string

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that the CLI api call works and handles exceptions" do

    # initialize new command instance
    command = Geb::CLI::Commands::Init.new

    site_path = "path/to/site"
    command_options = { template: "default", skip_template: false, skip_git: false, force: false }

    site_mock = mock('site')
    site_mock.expects(:validate).raises(Geb::Error.new("Test Error"))
    site_mock.stubs(:create)

    Geb::Site.stubs(:new).returns(site_mock)
    Geb::Git.stubs(:validate_git_repo)
    Geb::Git.stubs(:create_git_repo)

    # setup a StringIO to capture standard output and error
    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    command.call(site_path: site_path, **command_options)

    refute_empty $stderr.string
    assert_includes $stderr.string, "Test Error"

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works and handles exceptions"

  test "that command default executes" do

    new_site_path = "new_site"

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path}")

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "No template specified, using default: #{Geb::Defaults::DEFAULT_TEMPLATE}."
    assert_match(/Validating template path.*#{Geb::Defaults::DEFAULT_TEMPLATE}.*\.\.\. done\./, stdout)
    assert_includes stdout, "Validating proposed site path as a git repository ... done."
    refute_includes stdout, "Skipping git repository validation as told."

    assert_includes stdout, "Creating site folder: #{new_site_path} ... done."
    assert File.directory?(new_site_path)

    assert_includes stdout, "Copying template files to site folder ... done."
    assert_includes stdout, "Creating: local and release output folders ...done."
    assert File.directory?(File.join(new_site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
    assert File.directory?(File.join(new_site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    assert_includes stdout, "Initialising git repository ... done."
    refute_includes stdout, "Skipping git repository creation as told."
    assert File.directory?(File.join(new_site_path, ".git"))
    assert File.exist?(File.join(new_site_path, ".gitignore"))

  end # test "that command default executes"

  test "that new site can ignore git creation" do

    new_site_path = "new_site"

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --skip-git")

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "No template specified, using default: #{Geb::Defaults::DEFAULT_TEMPLATE}."
    assert_match(/Validating template path.*#{Geb::Defaults::DEFAULT_TEMPLATE}.*\.\.\. done\./, stdout)
    assert_includes stdout, "Skipping git repository validation as told."

    assert_includes stdout, "Creating site folder: #{new_site_path} ... done."
    assert File.directory?(new_site_path)

    assert_includes stdout, "Copying template files to site folder ... done."
    assert_includes stdout, "Creating: local and release output folders ...done."

    assert File.directory?(File.join(new_site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
    assert File.directory?(File.join(new_site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    refute_includes stdout, "Initialising git repository ... done."
    assert_includes stdout, "Skipping git repository creation as told."

    refute File.directory?(File.join(new_site_path, ".git"))
    refute File.exist?(File.join(new_site_path, ".gitignore"))

  end # test "that new site can ignore git creation"

  test "that new site can ignore template creation" do

    new_site_path = "new_site"

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --skip-template")

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "Skipping template validation as told."
    assert_includes stdout, "Validating proposed site path as a git repository ... done."
    refute_includes stdout, "Skipping git repository validation as told."

    assert_includes stdout, "Creating site folder: #{new_site_path} ... done."
    assert File.directory?(new_site_path)

    assert_includes stdout, "Skipping template creation as told."
    assert_includes stdout, "Creating: local and release output folders ...done."

    assert File.directory?(File.join(new_site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
    assert File.directory?(File.join(new_site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    assert_includes stdout, "Initialising git repository ... done."
    refute_includes stdout, "Skipping git repository creation as told."
    assert File.directory?(File.join(new_site_path, ".git"))
    assert File.exist?(File.join(new_site_path, ".gitignore"))

  end # test "that new site can ignore template creation"

  test "that new site can handle specified geb sample template" do

    new_site_path = "new_site"
    template = "bootstrap_jquery"

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --template #{template}")

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "Specified template is a Geb sample: #{template}, using it as site template."
    assert_match(/Validating template path.*#{template}.*\.\.\. done\./, stdout)
    assert_includes stdout, "Validating proposed site path as a git repository ... done."
    refute_includes stdout, "Skipping git repository validation as told."

    assert_includes stdout, "Creating site folder: #{new_site_path} ... done."
    assert File.directory?(new_site_path)

    assert_includes stdout, "Copying template files to site folder ... done."
    assert_includes stdout, "Creating: local and release output folders ...done."
    assert File.directory?(File.join(new_site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
    assert File.directory?(File.join(new_site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    assert_includes stdout, "Initialising git repository ... done."
    refute_includes stdout, "Skipping git repository creation as told."
    assert File.directory?(File.join(new_site_path, ".git"))
    assert File.exist?(File.join(new_site_path, ".gitignore"))

  end # test "that new site can handle specified geb sample template"

  test "that invalid specified template is handled correctly" do

    new_site_path = "new_site"
    template = "invalid_template_just_to_make_sure_3_for_sure"

    _, stderr, status = Open3.capture3("geb init #{new_site_path} --template #{template}")

    assert status.success?
    assert_includes stderr, "Invalid template site. Make sure the specified path is a directory and contains a valid gab.config.yml file."
    refute File.directory?(new_site_path)

  end # test "that invalid specified template is handled correctly"

  test "that template url is used correctly" do

    http_proxy = start_proxy

    new_site_path = "new_site"
    template_url = "#{http_proxy.base_url}/geb-template.tar.gz"

    http_proxy.stub_request(template_url, { 'Content-Type' => 'application/x-gzip' }) do
      File.read(File.join(File.dirname(__FILE__), "../files", "geb-template.tar.gz"))
    end

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --template #{template_url}")

    assert status.success?
    assert_empty stderr

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "Validating template URL #{template_url} ... done."
    assert_includes stdout, "Found a gzip archive at template url #{template_url}."
    assert_includes stdout, "Downloading template from URL #{template_url} ... done."

    assert_includes stdout, "Validating proposed site path as a git repository ... done."
    refute_includes stdout, "Skipping git repository validation as told."

    assert_includes stdout, "Creating site folder: #{new_site_path} ... done."
    assert File.directory?(new_site_path)

    assert_includes stdout, "Copying template files to site folder ... done."
    assert_includes stdout, "Creating: local and release output folders ...done."

    assert File.directory?(File.join(new_site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
    assert File.directory?(File.join(new_site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    assert_includes stdout, "Initialising git repository ... done."
    refute_includes stdout, "Skipping git repository creation as told."

    assert File.directory?(File.join(new_site_path, ".git"))
    assert File.exist?(File.join(new_site_path, ".gitignore"))

  end # test "that template url is used correctly"

  test "that invalid template url is handled correctly" do

    new_site_path = "new_site"
    template_url = "http://www.examplexyz7y.com/geb-template.tar.gz"

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --template #{template_url}")

    assert status.success?

    assert_includes stdout, "Validating site path #{new_site_path} ... done."
    assert_includes stdout, "Validating template URL #{template_url}"
    assert_includes stderr, "HTTP error"

    refute File.directory?(new_site_path)

  end # test "that invalid template url is handled correctly"

  test "that template url not being an archive is handled correctly" do

    http_proxy = start_proxy

    new_site_path = "new_site"
    template_url = "#{http_proxy.base_url}/geb-template.tar.gz"

    http_proxy.stub_request(template_url, { 'Content-Type' => 'text/plain' }, "This is not a tar.gz file")

    stdout, stderr, status = Open3.capture3("geb init #{new_site_path} --template #{template_url}")

    assert status.success?

    assert_includes stdout, "Validating site path #{new_site_path} ... done."

    assert_includes stdout, "Validating template URL #{template_url} ... done."
    assert_includes stderr, "Specified template is not a gzip archive"

    refute File.directory?(new_site_path)

  end # test "that template url not being an archive is handled correctly"

end # class TestGebCommandInit < Minitest::Test
