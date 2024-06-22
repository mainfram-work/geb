# frozen_string_literal: true

# include external libraries
require "dry/cli"

# include geb commands / libraries
require_relative "geb/version"
require_relative "geb/build"
require_relative "geb/release"
require_relative "geb/server"
require_relative "geb/init"
require_relative "geb/auto"
require_relative "geb/upload"
require_relative "geb/remote"
require_relative "geb/cli"

module Geb

  VERSION = "0.3.0"

  class Error < StandardError; end
  
end
