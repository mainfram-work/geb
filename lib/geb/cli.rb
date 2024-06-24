# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  The CLI Registry class, registers all the commands and their alises with
#  the Dry::CLI framework.
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include geb commands
require_relative "commands/version"
require_relative "commands/build"
require_relative "commands/release"
require_relative "commands/server"
require_relative "commands/init"
require_relative "commands/auto"
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
      register "auto",    Geb::CLI::Commands::Auto,     aliases: ["a", "-a", "--auto"]
      register "upload",  Geb::CLI::Commands::Upload,   aliases: ["u", "-u", "--upload"]
      register "remote",  Geb::CLI::Commands::Remote
      register "version", Geb::CLI::Commands::Version,  aliases: ["v", "-v", "--version"]

    end # module Commands
  end # module CLI
end # module Geb
