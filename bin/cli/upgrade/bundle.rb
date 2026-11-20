# frozen_string_literal: true

require_relative "../base"

module CLI
  module Upgrade
    class Bundle < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Upgrading gems"
        run "bundle update-interactive --latest"

        return if changed_files.empty?

        if rubocop_changed?
          say ""
          say "Rubocop gems have been updated."
          say ""
          say "Stopping rubocop server"
          run "rubocop --stop-server", abort_on_failure: false
        end

        say ""
        say "Would you like to run the CI ? [Yn]"
        run_ci_until_passed_or_discarded if ask == "Y"

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

              #{bin_prefix('upgrade')} bundle

          Upgrade bundle through an interactive command.
          Then, it suggests to commit the changes.
          \x5
        HEREDOC
      end

      protected

      def rubocop_changed?
        !run("git diff --quiet -G 'rubocop' Gemfile.lock", abort_on_failure: false)
      end

      def changed_files
        @changed_files ||= %w[
          Gemfile
          Gemfile.lock
        ].reject do |file|
          system("git", "diff", "--quiet", file)
        end
      end

      def commit_command
        "git commit -m \"Upgrade gem dependencies\" -- #{changed_files.join(' ')}"
      end

      def run_ci_until_passed_or_discarded
        loop do
          return true if run("bin/ci", abort_on_failure: false)

          say "Would you like to run again the CI ? [Yn]"
          return if ask != "Y"
        end
      end
    end
  end
end
