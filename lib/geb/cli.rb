# frozen_string_literal: true
#
# The CLI Registry class, registers all the commands and their aliases with
# the Dry::CLI framework.
#
# @title Geb - Command Registry
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

# include geb commands
require_relative "commands/version"
require_relative "commands/build"
require_relative "commands/release"
require_relative "commands/server"
require_relative "commands/init"
require_relative "commands/upload"
require_relative "commands/remote"

module Geb
  module CLI
    module Commands

      # this is the mail CLI registry class
      extend Dry::CLI::Registry

      # register all the commands and their aliases
      register "release", Geb::CLI::Commands::Release,  aliases: ["r", "-r", "--release"]
      register "build",   Geb::CLI::Commands::Build,    aliases: ["b", "-b", "--build"]
      register "server",  Geb::CLI::Commands::Server,   aliases: ["s", "-s", "--server"]
      register "init",    Geb::CLI::Commands::Init
      register "upload",  Geb::CLI::Commands::Upload,   aliases: ["u", "-u", "--upload"]
      register "remote",  Geb::CLI::Commands::Remote
      register "version", Geb::CLI::Commands::Version,  aliases: ["v", "-v", "--version"]

    end # module Commands
  end # module CLI
end # module Geb
