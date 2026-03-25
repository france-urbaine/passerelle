# frozen_string_literal: true

require_relative "../base"
require "bundler"

module CLI
  class Upgrade
    class Rubocop < Base
      def call
        say "Upgrading rubocop"

        gems = Bundler.locked_gems.dependencies.keys.grep(/^rubocop/)
        gems = gems.join(" ")

        run "bundle update #{gems}"

        say "Updating .rubocop_todo.yml"
        run "bundle exec rubocop --regenerate-todo"

        run "git commit -m \"Upgrade rubocop\" -- Gemfile.lock .rubocop_todo.yml"
      end
    end
  end
end
