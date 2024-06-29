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

class TestGebCommandServer < Geb::CliTest

  test "that the CLI api call works" do

    copy_test_site()

    command = Geb::CLI::Commands::Server.new
    server_port  = Geb::Test::WebServerProxy.find_available_port()

    command_options = { port: server_port, skip_build: false, skip_auto_build: false }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    server_thread = Thread.new do
      command.call(**command_options)
    end

    sleep 2

    command.force_shutdown()
    server_thread.join

    assert_includes($stdout.string, "Loading site from path #{Dir.pwd}")
    assert_includes($stdout.string, "Server running on http://localhost:#{@port}")
    assert_includes($stdout.string, "Watching for changes in [#{Dir.pwd}]")

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works"

  test "that the CLI api call works when an error is thrown" do

    # copy_test_site() # no site, so it should fail

    command = Geb::CLI::Commands::Server.new
    server_port  = Geb::Test::WebServerProxy.find_available_port()

    command_options = { port: server_port, skip_build: false, skip_auto_build: false }

    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    server_thread = Thread.new do
      command.call(**command_options)
    end

    sleep 2

    command.force_shutdown()
    server_thread.join

    refute_empty $stderr.string
    assert_includes($stdout.string, "Loading site from path #{Dir.pwd}")
    refute_includes($stdout.string, "Server running on http://localhost:#{@port}")
    refute_includes($stdout.string, "Watching for changes in [#{Dir.pwd}]")

    $stdout = original_stdout
    $stderr = original_stderr

  end # test "that the CLI api call works when an error is thrown"

  test "that command default executes" do

    copy_test_site()
    server_port  = Geb::Test::WebServerProxy.find_available_port()
    geb_command = "geb server --port #{server_port}"

    server_up = lambda do |output, error_output|
      output.include?("Server running on http://localhost:#{server_port}")
    end

    run_command_with_timeout(geb_command, break_condition: server_up) do |output, error_output|

      assert_includes output, "Loading site from path #{Dir.pwd}"
      assert_includes output, "Server running on http://localhost:#{server_port}"
      assert_includes output, "Watching for changes in [#{Dir.pwd}]"

    end # run_command_with_timeout

  end # test "that command default executes"

  test "that command handles being executed in a non-site directory" do

    # create a temporary directory
    Dir.mktmpdir do |dir|

      # change the current directory to the temporary directory
      Dir.chdir(dir)

      # call geb auto command and capture output and error
      _, stderr, status = Open3.capture3('geb server')

      # assert that the output contains the expected string
      assert status.success?
      assert_includes stderr, "is not and is not in a gab site. Could not find geb config file."

    end # Dir.mktmpdir

  end # test "that command handles being executed in a non-site directory"


  test "that command detects new file being added to the site" do

    skip "This test is not working yet"

    copy_test_site()
    server_port  = Geb::Test::WebServerProxy.find_available_port()
    geb_command = "geb server --port #{server_port}"

    new_file_path = File.join(Dir.pwd, "new_file.html")

    file_change_detected = lambda do |output, error_output|
      output.include?("Found changes, rebuilding site ...")
      #output.include?("Server running on http://localhost:#{server_port}")
    end

    add_file_event = lambda do |output, error_output|
      if output.include?("Watching for changes in [#{Dir.pwd}]")
        FileUtils.touch(new_file_path)
        File.write(new_file_path, "<html><body><h1>New File</h1></body></html>")
        return true
      else
        return false
      end
    end

    run_command_with_timeout(geb_command, timeout: 10, break_condition: file_change_detected, event: add_file_event) do |output, error_output|

      assert_includes output, "Loading site from path #{Dir.pwd}"
      assert_includes output, "Server running on http://localhost:#{server_port}"
      assert_includes output, "Watching for changes in [#{Dir.pwd}]"

    end # run_command_with_timeout

  end # test "that command default executes"

end # class TestGebCommandServer < Minitest::Test
