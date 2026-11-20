# frozen_string_literal: true

require_relative "../base"

module CLI
  module Upgrade
    class Yarn < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Upgrading JS dependencies"
        run "yarn upgrade-interactive --latest"

        return if changed_files.empty?

        say ""
        say "Updating assets"
        run "bin/setup test --assets"

        say ""
        say "Would you like to run the system specs ? [Yn]"
        run_system_specs_until_passed_or_discarded if ask == "Y"

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

              #{bin_prefix('upgrade')} yarn

          Upgrade JS packages through an interactive command.
          Then, it suggests to commit the changes.
          \x5
        HEREDOC
      end

      protected

      def changed_files
        @changed_files ||= %w[
          package.json
          yarn.lock
        ].reject do |file|
          system("git", "diff", "--quiet", file)
        end
      end

      def commit_command
        "git commit -m \"Upgrade JS dependencies\" -- #{changed_files.join(' ')}"
      end

      def run_system_specs_until_passed_or_discarded
        loop do
          return true if run("bin/ci test system", abort_on_failure: false)

          say "Would you like to run again the system specs ? [Yn]"
          return if ask != "Y"
        end
      end
    end
  end
end
