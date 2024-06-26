# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the CLI commands for Geb commands, making sure that DRY::CLI
#  structure is correctly implemented
#
#  Licence MIT
# -----------------------------------------------------------------------------
require "test_helper"

class TestGebCommands < Minitest::Test

  test "that geb has a version number" do
    refute_nil Geb::VERSION
  end # test "that geb has a version number"

  test "that all geb commands are registered" do

    refute_nil Geb::CLI::Commands::Release
    refute_nil Geb::CLI::Commands::Build
    refute_nil Geb::CLI::Commands::Server
    refute_nil Geb::CLI::Commands::Init
    refute_nil Geb::CLI::Commands::Auto
    refute_nil Geb::CLI::Commands::Upload
    refute_nil Geb::CLI::Commands::Remote
    refute_nil Geb::CLI::Commands::Version

    cli = Dry::CLI.new(Geb::CLI::Commands)
    registry = cli.instance_variable_get(:@registry)

    assert_cli_registered_command registry, "release", Geb::CLI::Commands::Release
    assert_cli_registered_command registry, "build",   Geb::CLI::Commands::Build
    assert_cli_registered_command registry, "server",  Geb::CLI::Commands::Server
    assert_cli_registered_command registry, "init",    Geb::CLI::Commands::Init
    assert_cli_registered_command registry, "auto",    Geb::CLI::Commands::Auto
    assert_cli_registered_command registry, "upload",  Geb::CLI::Commands::Upload
    assert_cli_registered_command registry, "remote",  Geb::CLI::Commands::Remote
    assert_cli_registered_command registry, "version", Geb::CLI::Commands::Version

  end # test "that all geb commands are registered"

  test "that geb has a build command" do

    refute_nil    Geb::CLI::Commands::Build
    refute_nil    Geb::CLI::Commands::Build.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Build.superclass

    refute_nil    Geb::CLI::Commands::Build.description,  "Build command should have a description."
    refute_empty  Geb::CLI::Commands::Build.description,  "Build command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Build.example,      "Build command should have an example."
    refute_empty  Geb::CLI::Commands::Build.example,      "Build command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Build.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Build.options, "Build command should have options."

    assert_cli_option Geb::CLI::Commands::Build, :skip_assets, :boolean, false
    assert_cli_option Geb::CLI::Commands::Build, :skip_pages,  :boolean, false

  end # test "that geb has a build command"

  test "that geb has a release command" do

    refute_nil    Geb::CLI::Commands::Release
    refute_nil    Geb::CLI::Commands::Release.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Release.superclass

    refute_nil    Geb::CLI::Commands::Release.description, "Release command should have a description."
    refute_empty  Geb::CLI::Commands::Release.description, "Release command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Release.example, "Release command should have an example."
    refute_empty  Geb::CLI::Commands::Release.example, "Release command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Release.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Release.options, "Release command should have options."

    assert_cli_option Geb::CLI::Commands::Release, :skip_assets, :boolean, false
    assert_cli_option Geb::CLI::Commands::Release, :skip_pages,  :boolean, false

  end # test "that geb has a release command"

  test "that geb has a server command" do

    refute_nil    Geb::CLI::Commands::Server
    refute_nil    Geb::CLI::Commands::Server.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Server.superclass

    refute_nil    Geb::CLI::Commands::Server.description, "Server command should have a description."
    refute_empty  Geb::CLI::Commands::Server.description, "Server command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Server.example, "Server command should have an example."
    refute_empty  Geb::CLI::Commands::Server.example, "Server command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Server.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Server.options, "Server command should have options."

    assert_cli_option Geb::CLI::Commands::Server, :port,       :int,     3456
    assert_cli_option Geb::CLI::Commands::Server, :skip_build, :boolean, false

  end # test "that geb has a server command"

  test "that geb has a init command" do

    refute_nil    Geb::CLI::Commands::Init
    refute_nil    Geb::CLI::Commands::Init.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Init.superclass

    refute_nil    Geb::CLI::Commands::Init.description, "Init command should have a description."
    refute_empty  Geb::CLI::Commands::Init.description, "Init command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Init.example, "Init command should have an example."
    refute_empty  Geb::CLI::Commands::Init.example, "Init command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Init.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Init.options, "Init command should have options."

    assert_cli_option Geb::CLI::Commands::Init, :template,            :string,  nil
    assert_cli_option Geb::CLI::Commands::Init, :skip_template,       :boolean, false
    assert_cli_option Geb::CLI::Commands::Init, :skip_git,            :boolean, false
    assert_cli_option Geb::CLI::Commands::Init, :force,               :boolean, false

  end # test "that geb has a init command"

  test "that geb has a auto command" do

    refute_nil    Geb::CLI::Commands::Auto
    refute_nil    Geb::CLI::Commands::Auto.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Auto.superclass

    refute_nil    Geb::CLI::Commands::Auto.description, "Auto command should have a description."
    refute_empty  Geb::CLI::Commands::Auto.description, "Auto command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Auto.example, "Auto command should have an example."
    refute_empty  Geb::CLI::Commands::Auto.example, "Auto command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Auto.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Auto.options, "Auto command should have options."

    assert_cli_option Geb::CLI::Commands::Auto, :skip_assets_build, :boolean, false
    assert_cli_option Geb::CLI::Commands::Auto, :skip_pages_build,  :boolean, false

  end # test "that geb has a auto command"

  test "that geb has a upload command" do

    refute_nil    Geb::CLI::Commands::Upload
    refute_nil    Geb::CLI::Commands::Upload.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Upload.superclass

    refute_nil    Geb::CLI::Commands::Upload.description, "Upload command should have a description."
    refute_empty  Geb::CLI::Commands::Upload.description, "Upload command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Upload.example, "Upload command should have an example."
    refute_empty  Geb::CLI::Commands::Upload.example, "Upload command's example should not be empty."

    refute_nil    Geb::CLI::Commands::Upload.method_defined?(:options)
    refute_empty  Geb::CLI::Commands::Upload.options, "Upload command should have options."

    assert_cli_option Geb::CLI::Commands::Upload, :skip_build,        :boolean, false
    assert_cli_option Geb::CLI::Commands::Upload, :skip_assets_build, :boolean, false
    assert_cli_option Geb::CLI::Commands::Upload, :skip_pages_build,  :boolean, false

  end # test "that geb has a upload command"

  test "that geb has a remote command" do

    refute_nil    Geb::CLI::Commands::Remote
    refute_nil    Geb::CLI::Commands::Remote.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Remote.superclass

    refute_nil    Geb::CLI::Commands::Remote.description, "Remote command should have a description."
    refute_empty  Geb::CLI::Commands::Remote.description, "Remote command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Remote.example, "Remote command should have an example."
    refute_empty  Geb::CLI::Commands::Remote.example, "Remote command's example should not be empty."

  end # test "that geb has a remote command"

  test "that geb has a version command" do

    refute_nil    Geb::CLI::Commands::Version
    refute_nil    Geb::CLI::Commands::Version.method_defined?(:call)
    assert_equal  Dry::CLI::Command, Geb::CLI::Commands::Version.superclass

    refute_nil    Geb::CLI::Commands::Version.description, "Version command should have a description."
    refute_empty  Geb::CLI::Commands::Version.description, "Version command's description should not be empty."
    refute_nil    Geb::CLI::Commands::Version.example, "Version command should have an example."
    refute_empty  Geb::CLI::Commands::Version.example, "Version command's example should not be empty."

  end # test "that geb has a version command"

end # class TestGebCommands < Minitest::Test
