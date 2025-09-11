# frozen_string_literal: true

require_relative "../base"

module CLI
  class Upgrade
    class Bundle < Base
      def call
        say "Upgrading gems"
        run "bundle update-interactive --latest"

        return unless gemfile_lock_changed?

        if rubocop_changed?
          say ""
          say "Some rubocop gems have been updated."
          say ""
          say "Stopping rubocop server"
          run "rubocop --stop-server", abort_on_failure: false
        end

        say ""
        say "Some gems have been updated."
        say ""
        say "Would you like to run the CI ? [Yn]"
        run_ci_until_passed_or_discarded if ask == "Y"

        say ""
        say "Would you like to commit changes to Gemfile.lock ? [Yn]"
        run "git commit -m \"Update gems dependencies\" -- Gemfile Gemfile.lock" if ask == "Y"
      end

      protected

      def gemfile_lock_changed?
        !run("git diff --quiet Gemfile.lock", abort_on_failure: false)
      end

      def rubocop_changed?
        !run("git diff --quiet -G 'rubocop' Gemfile.lock", abort_on_failure: false)
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
