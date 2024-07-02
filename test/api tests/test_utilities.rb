# frozen_string_literal: true
#
# Tests the utilities class
#
# @title Geb - Test - Utilities
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class UtilitiesTest < Minitest::Test

  test "that Geb error raises a correct error message" do

    # assert that the error message is correct
    error = assert_raises(Geb::Error) do
      raise Geb::Error.new("Custom Error", "Default Message")
    end # assert_raises(Geb::Error)

    assert_equal("Custom Error Default Message", error.message)

  end # test "that Geb error raises a correct error message"

  test "that log prints a message to the console and has a trailing newline" do

      # setup a StringIO to capture standard output
      original_stdout = $stdout
      $stdout = StringIO.new

      # call the log method
      Geb.log("Test Message")

      # assert that the message is correct
      assert_equal("Test Message\n", $stdout.string)

      # reset $stdout
      $stdout = original_stdout

  end # test "that log prints a message to the console and has a trailing newline"

  test "that log_start prints a message to the console and does not have a trailing newline" do

      # setup a StringIO to capture standard output
      original_stdout = $stdout
      $stdout = StringIO.new

      # call the log method
      Geb.log_start("Test Message")

      # assert that the message is correct
      assert_equal("Test Message", $stdout.string)

      # reset $stdout
      $stdout = original_stdout

  end # test "that log_start prints a message to the console and does not have a trailing newline"

  test "that logging can be suppressed" do

    # setup a StringIO to capture standard output
    original_stdout = $stdout
    $stdout = StringIO.new

    Geb.no_log do
      Geb.log("Test Message")
    end

    assert_equal("", $stdout.string)

    Geb.log("Test Message2")

    assert_equal("Test Message2\n", $stdout.string)

    # reset $stdout
    $stdout = original_stdout

  end # test "that logging can be suppressed"

  test "that copy paths to directory copies files and directories to a destination directory" do

    # initialize a temporary directory
    Dir.mktmpdir do |tmpdir|

      test_source_directory       = File.join(tmpdir, "source")
      test_destination_directory  = File.join(tmpdir, "destination")
      Dir.mkdir(test_source_directory)
      Dir.mkdir(test_destination_directory)

      file_paths = []
      file_paths << File.join(test_source_directory, "folder1")
      file_paths << File.join(test_source_directory, "folder2")
      file_paths << File.join(test_source_directory, "folder2/subfolder1")
      file_paths << File.join(test_source_directory, "folder2/subfolder2")
      file_paths << File.join(test_source_directory, "file1.txt")
      file_paths << File.join(test_source_directory, "file2.txt")
      file_paths << File.join(test_source_directory, "folder2/file2-1.txt")
      file_paths << File.join(test_source_directory, "folder2/file2-1.txt")
      file_paths << File.join(test_source_directory, "folder2/subfolder2/files2-1-1.txt")
      file_paths.each do |path|
        if path !~ /\./
          FileUtils.mkdir_p(path)
        else
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, "w") do |file|
            file.write("This is a dumny file path: #{path}")
          end
        end
      end

      Geb::copy_paths_to_directory(test_source_directory, file_paths, test_destination_directory, true)

      file_paths.each do |path|
        destination_path = path.gsub(test_source_directory, test_destination_directory)
        if path !~ /\./
          assert Dir.exist?(destination_path)
        else
          assert File.exist?(destination_path)
        end
      end

    end # Dir.mktmpdir

  end # test "that copy paths to directory copies files and directories to a destination directory"

  test "that copy paths to directory raises an error if the file operations fail" do

    # initialize a temporary directory
    Dir.mktmpdir do |tmpdir|

      test_source_directory       = File.join(tmpdir, "source")
      test_destination_directory  = File.join(tmpdir, "destination")
      Dir.mkdir(test_source_directory)
      Dir.mkdir(test_destination_directory)

      FileUtils.stubs(:mkdir_p).raises(Errno::EACCES)

      file_paths = []
      file_paths << File.join(test_source_directory, "folder1")
      file_paths << File.join(test_source_directory, "folder2")
      file_paths << File.join(test_source_directory, "folder2/subfolder1")
      file_paths << File.join(test_source_directory, "folder2/subfolder2")
      file_paths << File.join(test_source_directory, "file1.txt")
      file_paths << File.join(test_source_directory, "file2.txt")
      file_paths << File.join(test_source_directory, "folder2/file2-1.txt")
      file_paths << File.join(test_source_directory, "folder2/file2-1.txt")
      file_paths << File.join(test_source_directory, "folder2/subfolder2/files2-1-1.txt")

      error = assert_raises(Geb::Error) do
        Geb::copy_paths_to_directory(test_source_directory, file_paths, test_destination_directory, true)
      end

      assert_includes error.message, "Permission denied"
      assert_includes error.message, "Failed to copy paths to directory"

    end # Dir.mktmpdir

  end # test "that copy paths to directory raises an error if the file operations fail"

end # class UtilitiesTest < Geb::ApiTest
