# frozen_string_literal: true
#
# Tests the server class
#
# @title Geb - Test - Server
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestServer < Geb::ApiTest

  test "that server initializer handles the auto_build flag set to true" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})

    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)

    WEBrick::HTTPServer.expects(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, true)

    assert_instance_of Geb::Server, server

    refute_nil server.instance_variable_get(:@http_server)
    refute_nil server.instance_variable_get(:@file_watcher)

  end # test "that server initializer handles the auto_build flag set to true"

  test "that server initializer handles the auto_build flag set to false" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})

    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)

    WEBrick::HTTPServer.expects(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, false)

    assert_instance_of Geb::Server, server

    refute_nil server.instance_variable_get(:@http_server)
    assert_nil server.instance_variable_get(:@file_watcher)

  end # test "that server initializer handles the auto_build flag set to false"

  test "that server start method starts the http server and file watcher" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.expects(:start)
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})

    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)
    file_watcher_mock.expects(:start)

    WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, true)

    server.start

    sleep 0.1

    http_server_thread = server.instance_variable_get(:@http_server_thread)
    file_watcher_thread = server.instance_variable_get(:@file_watcher_thread)

    refute_nil server.instance_variable_get(:@http_server_thread)
    refute_nil server.instance_variable_get(:@file_watcher_thread)
    assert_instance_of Thread, server.instance_variable_get(:@http_server_thread)
    assert_instance_of Thread, server.instance_variable_get(:@file_watcher_thread)

    http_server_thread.kill
    file_watcher_thread.kill

  end # test "that server start method starts the http server and file watcher"

  test "that server start methods starts the http server and not the file watcher" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.expects(:start)
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})

    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)
    file_watcher_mock.expects(:start).never

    WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, false)

    server.start

    sleep 0.1

    http_server_thread = server.instance_variable_get(:@http_server_thread)
    file_watcher_thread = server.instance_variable_get(:@file_watcher_thread)

    refute_nil server.instance_variable_get(:@http_server_thread)
    assert_nil server.instance_variable_get(:@file_watcher_thread)
    assert_instance_of Thread, server.instance_variable_get(:@http_server_thread)
    assert_nil file_watcher_thread

    http_server_thread.kill

  end # test "that server start methods starts the http server and not the file watcher"

  test "that server stop method stops the http server and file watcher" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
    http_server_mock.expects(:start)
    http_server_mock.expects(:shutdown)


    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)
    file_watcher_mock.expects(:start)
    file_watcher_mock.expects(:stop)

    WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, true)

    server.start

    sleep 0.1

    server.stop

    refute server.instance_variable_get(:@http_server_thread).alive?
    refute server.instance_variable_get(:@file_watcher_thread).alive?

  end # test "that server stop method stops the http server and file watcher"

  test "that server stop method stops the http server and not the file watcher" do

    site_mock = mock('site')
    site_mock.stubs(:site_path).returns('site_path')
    site_mock.stubs(:get_site_local_output_directory).returns('site_path/output')
    site_mock.stubs(:get_site_release_output_directory).returns('site_path/release')

    http_server_mock = mock('webric_httpserver')
    http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
    http_server_mock.expects(:start)
    http_server_mock.expects(:shutdown)

    file_watcher_mock = mock('file_watcher')
    file_watcher_mock.stubs(:ignore)
    file_watcher_mock.expects(:start).never

    WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
    Listen.stubs(:to).returns(file_watcher_mock)

    server = Geb::Server.new(site_mock, 3456, false)

    server.start

    sleep 0.1

    server.stop

    refute server.instance_variable_get(:@http_server_thread).alive?
    assert_nil server.instance_variable_get(:@file_watcher_thread)

  end # test "that server stop method stops the http server and not the file watcher"

  test "that server get_http_server method returns a webrick http server instance" do

    # get the next available port
    port = Geb::Test::WebServerProxy.find_available_port

    # create a temporary directory
    Dir.mktmpdir do |dir|

      site_mock = mock('site')
      site_mock.stubs(:site_path).returns(dir)
      site_mock.stubs(:get_site_local_output_directory).returns(dir)
      site_mock.stubs(:get_site_release_output_directory).returns(dir)
      http_server_mock = mock('webric_httpserver')
      http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
      file_watcher_mock = mock('file_watcher')
      file_watcher_mock.stubs(:ignore)

      WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
      Listen.stubs(:to).returns(file_watcher_mock)

      geb_server = Geb::Server.new(site_mock, port, true)

      WEBrick::HTTPServer.unstub(:new)

      original_stdout = $stdout
      original_stderr = $stderr

      $stdout = StringIO.new
      $stderr = StringIO.new

      http_server = geb_server.send(:get_http_server)

      # restore stdout and stderr
      $stdout = original_stdout
      $stderr = original_stderr

      assert_instance_of WEBrick::HTTPServer, http_server
      assert_equal port,  http_server.config[:Port]
      assert_equal dir,   http_server.config[:DocumentRoot]

    end # Dir.mktmpdir

  end # test "that server get_http_server method returns a webrick http server instance"

  test "that server get_file_watcher method returns a listen instance" do

    # create a temporary directory
    Dir.mktmpdir do |dir|

      site_mock = mock('site')
      site_mock.stubs(:site_path).returns(dir)
      site_mock.stubs(:get_site_local_output_directory).returns(dir)
      site_mock.stubs(:get_site_release_output_directory).returns(dir)
      http_server_mock = mock('webric_httpserver')
      http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
      file_watcher_mock = mock('file_watcher')
      file_watcher_mock.stubs(:ignore)

      WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
      Listen.stubs(:to).returns(file_watcher_mock)

      geb_server = Geb::Server.new(site_mock, 8888, true)

      Listen.unstub(:to)
      file_watcher  = geb_server.send(:get_file_watcher)
      backend       = file_watcher.instance_variable_get(:@backend)
      adapter       = backend.instance_variable_get(:@adapter)
      config        = adapter.instance_variable_get(:@config)

      assert_instance_of Listen::Listener, file_watcher
      assert_includes  config.directories.first.to_s, dir

    end # Dir.mktmpdir

  end # test "that server get_file_watcher method returns a listen instance"

  test "that the server detects file changes and rebuilds the site" do

    # create a temporary directory
    Dir.mktmpdir do |dir|

      site_dir = File.join(dir, 'newsite')
      site_output_directory = File.join(site_dir, 'output/local')
      site_release_directory = File.join(site_dir, 'output/release')

      file_path_add = File.join(site_dir, 'add.html')
      file_path_modify = File.join(site_dir, 'modify.html')
      file_path_delete = File.join(site_dir, 'delete.html')

      FileUtils.mkdir_p(site_dir)
      FileUtils.mkdir_p(site_output_directory)
      FileUtils.mkdir_p(site_release_directory)

      FileUtils.touch(file_path_modify)
      File.write(file_path_modify, 'modify file original content')
      FileUtils.touch(file_path_delete)
      File.write(file_path_delete, 'delete file content')

      site_mock = mock('site')
      site_mock.stubs(:site_path).returns(site_dir)
      site_mock.stubs(:get_site_local_output_directory).returns(site_output_directory)
      site_mock.stubs(:get_site_release_output_directory).returns(site_release_directory)
      site_mock.expects(:build).times(1)

      http_server_mock = mock('webric_httpserver')
      http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
      file_watcher_mock = mock('file_watcher')
      file_watcher_mock.stubs(:ignore)

      WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
      Listen.stubs(:to).returns(file_watcher_mock)

      geb_server = Geb::Server.new(site_mock, 8888, true)

      Listen.unstub(:to)

      log_output = ""
      Geb.stubs(:log_start) { |*args| log_output << args.first }
      Geb.stubs(:log)       { |*args| log_output << args.first }

      # initialize a sequence
      Geb.expects(:log_start).times(1).with("Found changes, rebuilding site ... ")
      Geb.expects(:log).times(4)

      file_watcher = geb_server.send(:get_file_watcher)

      file_watcher.start

      sleep 0.5

      FileUtils.touch(file_path_add)
      File.write(file_path_add, 'add file content')
      File.write(file_path_modify, 'modify file modified content')
      FileUtils.rm(file_path_delete)

      sleep 0.5

      file_watcher.stop

    end # Dir.mktmpdir

  end # test "that the server detects file changes and rebuilds the site"


  test "that the server detects file changes handles exception is build fails" do

    # create a temporary directory
    Dir.mktmpdir do |dir|

      site_dir = File.join(dir, 'newsite')
      site_output_directory = File.join(site_dir, 'output/local')
      site_release_directory = File.join(site_dir, 'output/release')

      file_path_add = File.join(site_dir, 'add.html')
      file_path_modify = File.join(site_dir, 'modify.html')
      file_path_delete = File.join(site_dir, 'delete.html')

      FileUtils.mkdir_p(site_dir)
      FileUtils.mkdir_p(site_output_directory)
      FileUtils.mkdir_p(site_release_directory)

      FileUtils.touch(file_path_modify)
      File.write(file_path_modify, 'modify file original content')
      FileUtils.touch(file_path_delete)
      File.write(file_path_delete, 'delete file content')

      site_mock = mock('site')
      site_mock.stubs(:site_path).returns(site_dir)
      site_mock.stubs(:get_site_local_output_directory).returns(site_output_directory)
      site_mock.stubs(:get_site_release_output_directory).returns(site_release_directory)
      site_mock.expects(:build).raises(Geb::Error, "Build failed")

      http_server_mock = mock('webric_httpserver')
      http_server_mock.stubs(:config).returns({:Port => 3456, :DocumentRoot => 'site_path/output'})
      file_watcher_mock = mock('file_watcher')
      file_watcher_mock.stubs(:ignore)

      WEBrick::HTTPServer.stubs(:new).returns(http_server_mock)
      Listen.stubs(:to).returns(file_watcher_mock)

      geb_server = Geb::Server.new(site_mock, 8888, true)

      Listen.unstub(:to)

      log_output = ""
      Geb.stubs(:log_start) { |*args| log_output << args.first }
      Geb.stubs(:log)       { |*args| log_output << args.first }

      # initialize a sequence
      Geb.expects(:log_start).times(1).with("Found changes, rebuilding site ... ")
      Geb.expects(:log).times(4)

      file_watcher = geb_server.send(:get_file_watcher)

      file_watcher.start

      sleep 0.5

      FileUtils.touch(file_path_add)
      File.write(file_path_add, 'add file content')
      File.write(file_path_modify, 'modify file modified content')
      FileUtils.rm(file_path_delete)

      sleep 0.5

      file_watcher.stop

    end # Dir.mktmpdir

  end # test "that the server detects file changes and rebuilds the site"

end # class TestServer < Geb::ApiTest
