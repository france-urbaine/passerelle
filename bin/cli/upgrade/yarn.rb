# frozen_string_literal: true

require_relative "../base"

module CLI
  class Upgrade
    class Yarn < Base
      def call
        say "Upgrading JS dependencies"
        run "yarn upgrade-interactive --latest"

        return unless yarn_lock_changed?

        say ""
        if package_changed?
          say "package.json & yarn.lock have changed."
        else
          say "yarn.lock has changed."
        end

        say ""
        say "Updating assets"
        run "bin/setup test assets"

        say ""
        say "Would you like to run the system specs ? [Yn]"
        run_system_specs_until_passed_or_discarded if ask == "Y"
        say ""

        if package_changed?
          say "Would you like to see changes on package.json ? [Yn]"
          run "git diff package.json" if ask == "Y"

          say ""
          say "Would you like to commit changes on yarn.lock & package.json ? [Yn]"
          run "git commit -m \"Update JS dependencies\" -- package.json yarn.lock" if ask == "Y"

        else
          say "Would you like to commit changes on yarn.lock ? [Yn]"
          run "git commit -m \"Update JS dependencies\" -- yarn.lock" if ask == "Y"
        end
      end

      protected

      def yarn_lock_changed?
        !run("git diff --quiet yarn.lock", abort_on_failure: false)
      end

      def package_changed?
        !run("git diff --quiet package.json", abort_on_failure: false)
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
