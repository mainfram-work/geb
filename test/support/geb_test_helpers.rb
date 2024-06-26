# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  A collection of Geb test helper methods:
#
#  assert_stdout_match            - asserts that the standard output matches a pattern
#  refute_stdout_match            - asserts that the standard output does not match a pattern
#  assert_stderr_match            - asserts that the standard error matches a pattern
#  refute_stderr_match            - asserts that the standard error does not match a pattern
#  assert_cli_registered_command  - asserts that a command is registered in the CLI registry
#  assert_cli_option              - asserts that a command has a specific option defined
#  assert_folder_copied           - asserts that a folder has been copied to another folder
#
#  Licence MIT
# -----------------------------------------------------------------------------

def assert_stdout_match(p_match)

  $stdout.rewind
  output = $stdout.string
  assert_match p_match, output

end # def assert_stdout_match

def refute_stdout_match(p_match)

  $stdout.rewind
  output = $stdout.string
  refute_match p_match, output

end # def refute_stdout_match

def assert_stderr_match(p_match)

  $stderr.rewind
  output = $stderr.string
  assert_match p_match, output

end # def assert_stderr_match

def refute_stderr_match(p_match)

  $stderr.rewind
  output = $stderr.string
  refute_match p_match, output

end # def refute_stderr_match

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

# check if a folder has been copied to another folder
def assert_folder_copied(folder_from, folder_to)

  folder_from_entries = Dir.glob("#{folder_from}/**/*", File::FNM_DOTMATCH).map { |e| e.sub("#{folder_from}/", '') }.reject { |e| e == '.' || e == '..' }
  folder_to_entries =   Dir.glob("#{folder_to}/**/*", File::FNM_DOTMATCH).map { |e| e.sub("#{folder_to}/", '') }.reject { |e| e == '.' || e == '..' }

  assert (folder_from_entries - folder_to_entries).empty?

end # def assert_folder_copied
