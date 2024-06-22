# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Geb gem rakefile
#
#  Licence MIT
# -----------------------------------------------------------------------------

# include the gem tasks
require "bundler/gem_tasks"
require "minitest/test_task"
# no need to require bundler/setup, it's already done in the gemspec

# setup the test task
Minitest::TestTask.create

# setup the default task (so we don't have to do rake test, just rake will do)
task default: :test
