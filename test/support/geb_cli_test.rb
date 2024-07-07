# frozen_string_literal: true
#
# This is a CLI test base class for Geb.  It provides a consistent setup and
# teardown for CLI tests. Current setup and teardown handle the following
# tasks:
#  - It checks the version of the command being tested on the setup and asserts
#    that the version number in Geb::Version is the same as running command `geb version`
#  - Creates a temporary directory and changes to it, removes it after the test
#  - Sets up a proxy server if the PROXY_PORT is defined, stops server after the test
#
# @title Geb - Test Support - CLI Test
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

module Geb
  class CliTest < Minitest::Test

    PROXY_PORT = 8888

    # Common setup logic
    # redirects stdout and stderr to StringIO
    # creates a temporary directory and changes to it
    def setup

      # setup a temporary directory and change to it
      @temp_dir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@temp_dir)

      # initialize the proxy instance
      @proxy = nil

      # make sure the version of the command being tested is the latest code version
      assert_geb_command_version()

    end # def setup

    # Common teardown logic
    # redirects stdout and stderr back to their original state
    # changes back to the original directory
    def teardown

      Dir.chdir(@original_dir)
      FileUtils.remove_entry @temp_dir

      # stop the web server if it is defined and running
      @proxy.stop if @proxy && @proxy.running?

    end # def teardown

    # Starts the proxy server if the PROXY_PORT is defined
    def start_proxy

      # start the proxy server only if the PROXY_PORT is defined
      if PROXY_PORT

        # start the web server
        @proxy = Geb::Test::WebServerProxy.new(PROXY_PORT, debug: false)
        @proxy.start

      end # if PROXY_PORT

      # return the proxy instance
      return @proxy

    end # def start_proxy

    # copy the test site into the current directory
    def copy_test_site

        # get the test site path
        test_site_path = File.expand_path(File.join(__dir__, '..', 'files/test-site'))

        # copy the test site contents into the current directory
        FileUtils.cp_r(File.join(test_site_path, '.'), Dir.pwd)

    end # def copy_test_site

    # compare the output of the command with the expected internal Geb version
    def assert_geb_command_version

      # call the geb version command and capture output and error
      stdout, _, status = Open3.capture3("geb version")

      # assert that the output contains the expected string
      assert status.success?
      assert_includes stdout, "Geb version #{Geb::VERSION}"

    end # def assert_geb_command_version

    # run the command with a timeout and a break condition, useful for testing
    # processes that may hang or run indefinitely
    # @param command [String] the command to run
    # @param timeout [Integer] the timeout in seconds
    # @param break_condition [Proc] a block that will be called with the output and error
    # @yieldparam output [String] the output of the command
    # @yieldparam error_output [String] the error output of the command
    def run_command_with_timeout(command, timeout: 10, break_condition: nil, event: nil)

      # initialize the output and error output
      output, error_output = "", ""

      # run the command with a timeout
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|

        # lets make sure we can safely kill the command
        begin

          # initialize a flag indicating if the event was executed
          event_executed = false

          # Timeout the command after the specified time
          Timeout.timeout(timeout) do

            # read the output and error output until the break condition is met or the timeout is reached
            loop do

              # lets do this safely
              begin

                # read the output and error output
                output        += stdout.read_nonblock(4028) rescue ""
                error_output  += stderr.read_nonblock(4028) rescue ""

                # call the event if it is defined and has not been executed
                if event && !event_executed
                  Thread.new do
                    event_executed = event.call(output, error_output)
                  end
                end # if

                # break if the break condition is met. call the break condition lambda
                # passed in as parameter with the output and error output
                break if break_condition && break_condition.call(output, error_output)

              rescue IO::WaitReadable

                # wait for the IO to be readable
                IO.select([stdout, stderr])

                retry

              rescue EOFError

                # break if the command has finished
                break

              end # begin rescue
            end # loop
          end # Timeout.timeout

        ensure

          # gracefully shutdown the process and wait for it to terminate
          Process.kill("INT", wait_thr.pid)
          wait_thr.value

        end # begin ensure
      end # Open3.popen3

      # yield to the block if it is given and return the output and error output,
      # this is where test assertions should be made
      yield output, error_output if block_given?

    end # def run_command_with_timeout


    # run the command with a timeout and a break condition, useful for testing
    # processes that may hang or run indefinitely
    # @param command [String] the command to run
    # @param timeout [Integer] the timeout in seconds
    # @param break_condition [Proc] a block that will be called with the output and error
    # @yieldparam output [String] the output of the command
    # @yieldparam error_output [String] the error output of the command
    def run_command_with_timeout2(command, timeout: 10, break_condition: nil, event: nil)

      # initialize the output and error output
      output, error_output = "", ""

      # initialize a flag indicating if the event was executed
      event_executed = false

      # initialize a new mutex
      mutex = Mutex.new

      # initialize a condition variable for signaling
      condition_variable = ConditionVariable.new

      event_thread = Thread.new do
        event.call
      end

      # run the command with within a thread
      command_thread = Thread.new do

        # run the command with a timeout
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|

          # lets make sure we can safely kill the command
          begin

            # Timeout the command after the specified time
            Timeout.timeout(timeout) do

              # read the output and error output until the break condition is met or the timeout is reached
              loop do

                # lets do this safely
                begin

                  # synchronize the mutex
                  mutex.synchronize do

                  # read the output and error output
                    output        += stdout.read_nonblock(4028) rescue ""
                    error_output  += stderr.read_nonblock(4028) rescue ""

                  end # mutex.synchronize

                  # break if the break condition is met. call the break condition lambda
                  # passed in as parameter with the output and error output
                  if break_condition && break_condition.call(output, error_output, event_executed)
                    condition_variable.signal
                    break
                  end

                rescue IO::WaitReadable

                  # wait for the IO to be readable
                  IO.select([stdout, stderr])

                  retry

                rescue EOFError

                  # break if the command has finished
                  break

                end # begin rescue
              end # loop
              condition_variable.signal
            end # Timeout.timeout

          ensure

            # gracefully shutdown the process and wait for it to terminate
            Process.kill("INT", wait_thr.pid)
            wait_thr.value

          end # begin ensure
        end # Open3.popen3

      end # Thread.new

       # wait for the thread to finish or timeout
      mutex.synchronize do
        unless condition_variable.wait(mutex, timeout)
          # Timeout reached, kill the thread
          Thread.kill(command_thread)
          Thread.kill(event_thread)
        end
      end

      # yield to the block if it is given and return the output and error output,
      # this is where test assertions should be made
      yield output, error_output if block_given?

    end # def run_command_with_timeout

  end # class CliTest < Minitest::Test

end # module Geb
