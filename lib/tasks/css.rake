# frozen_string_literal: true

# FIXME: Monkeypatch of cssbundling-rails
#
# In production, bun is already be pre-installed
# When running `rails assets:precompile', cssbundling-rails detects bun
# and decides to use it over yarn.
#
# So we need to override the task provided by cssbundling-rails
#
# We could remove that file after the following commit is released:
# https://github.com/rails/cssbundling-rails/commit/57de5eff4d4b8aabf9862181634fbd265f93afe4
#
# rubocop:disable Rails/RakeEnvironment
# Including `environment` task is not necessary
#
namespace :css do
  desc "Install CSS dependencies"
  task :install do
    command = Cssbundling::Tasks.install_command
    unless system("yarn install")
      raise "cssbundling-rails: Command install failed, ensure #{command.split.first} is installed"
    end
  end

  desc "Build your CSS bundle"
  build_task = task :build do
    command = Cssbundling::Tasks.build_command
    unless system("yarn build:css")
      raise "cssbundling-rails: Command build failed, ensure `#{command}` runs without errors"
    end
  end
  build_task.prereqs << :install unless ENV["SKIP_YARN_INSTALL"] || ENV["SKIP_BUN_INSTALL"]
end
#
# rubocop:enable Rails/RakeEnvironment
