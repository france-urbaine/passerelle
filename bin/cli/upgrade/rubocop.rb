# frozen_string_literal: true

require_relative "../base"

module CLI
  module Upgrade
    class Rubocop < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Upgrading rubocop"

        require "bundler"
        gems = Bundler.locked_gems.dependencies.keys.grep(/^rubocop/)
        gems = gems.join(" ")

        run "bundle update #{gems}"

        say "Updating .rubocop_todo.yml"
        run "bundle exec rubocop --regenerate-todo"

        return if changed_files.empty?

        say ""
        say "Changed files:"
        say ""
        changed_files.each do |file|
          say "  #{colorize(file, :RED)}"
        end

        say ""

        if inside_docker_container?
          say "To commit changes, run this command from your host:"
          say ""
          say "    #{colorize(commit_command, :YELLOW)}"
          say ""
        else
          say "Would you like to commit changes? [Yn]"
          run commit_command if ask == "Y"
        end
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('upgrade')} rubocop

          Upgrade rubocop gems and the todo file.
          Then, it suggests to commit the changes.
          \x5
        HEREDOC
      end

      protected

      def changed_files
        @changed_files ||= %w[
          Gemfile.lock
          .rubocop_todo.yml
        ].reject do |file|
          system("git", "diff", "--quiet", file)
        end
      end

      def commit_command
        "git commit -m \"Upgrade rubocop\" -- #{changed_files.join(' ')}"
      end
    end
  end
end
