# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Minitest test helper class. Contains various helper methods for testing
#
#  assert_stdout_match            - asserts that the standard output matches a pattern
#  assert_cli_registered_command  - asserts that a command is registered in the CLI registry
#  assert_cli_option              - asserts that a command has a specific option defined
#
#  Licence MIT
# -----------------------------------------------------------------------------

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "geb"
require "minitest/autorun"
require "stringio"

# ::: Helpers :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

def assert_stdout_match(p_match)

  $stdout.rewind
  output = $stdout.string
  assert_match p_match, output

end # def assert_stdout_match

def assert_cli_registered_command(p_registry, p_command, p_class)

  command_lookup = p_registry.get([p_command])
  assert command_lookup.found?, "Command '#{p_command}' should be registered"

  assert_equal p_class, command_lookup.command

end # def assert_cli_registered_command

def assert_cli_option(p_command_class, p_option_name, p_type, p_default)

  option = p_command_class.options.find { |o| o.name == p_option_name }
  command_name = p_command_class.name.split("::").last

  # make sure the option is defined
  refute_nil    option,                     "#{command_name} command should have a #{p_option_name} option."
  assert_equal  p_type, option.type,        "#{command_name} command #{p_option_name} option should be #{p_type}."
  assert_equal  p_default, option.default,  "#{command_name} command #{p_option_name} option should default to #{p_default}." unless p_default.nil?
  refute_nil    option.desc,                "#{command_name} command #{p_option_name} option should have a description."
  refute_empty  option.desc,                "#{command_name} command #{p_option_name} option description should not be empty."

end # def assert_cli_option
