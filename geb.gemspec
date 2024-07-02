# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Geb gemspec file
#  For more information and examples about making a new gem, check out our
#  guide at: https://bundler.io/guides/creating_gem.html
#
#  Licence MIT
# -----------------------------------------------------------------------------
#require_relative "lib/geb"

Gem::Specification.new do |spec|

  # basic gem information
  spec.name         = "geb"
  spec.version      = "0.3.11"
  spec.authors      = ["Edin Mustajbegovic"]
  spec.email        = ["edin@actiontwelve.com"]
  spec.summary      = "A static website builder with simple templating and management utilities."
  spec.description  = "A static website builder with simple templating and management utilities."
  spec.homepage     = "https://github.com/mainfram-work/geb"
  spec.license      = "MIT"

  # setup gem metadata
  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = spec.homepage
  spec.metadata["changelog_uri"]    = "https://github.com/mainfram-work/geb/blob/main/CHANGELOG.md"

  # ruby version, dependencies and other settings
  spec.required_ruby_version = ">= 3.0.0"
  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "webrick", "~> 1.8"
  spec.add_dependency 'listen', "~> 3.9"
  spec.add_dependency 'minitar', "~> 0.9"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'mocha', '~> 2.1'
  spec.add_development_dependency 'yard', '~> 0.9'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  # setup bin directory, executables and require paths
  spec.bindir         = "bin"
  spec.executables    = ['geb']
  spec.require_paths  = ["lib"]
  spec.test_files     = Dir['test/**/*.rb']

end # Gem::Specification.new
