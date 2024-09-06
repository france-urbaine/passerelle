# frozen_string_literal: true

require_relative "../base"

module CLI
  class Upgrade
    class Yarn < Base
      def call
        say "Updating JS dependencies"
        run "yarn upgrade-interactive --latest"

        if package_changed? && yarn_lock_changed?
          say ""
          say "package.json & yarn.lock have changed."
          say ""
          say "Would you like to see changes on package.json ? [Yn]"
          run "git diff package.json" if ask == "Y"

          say ""
          say "Would you like to commit changes on yarn.lock & package.json ? [Yn]"
          run "git commit -m \"Update JS dependencies\" -- package.json yarn.lock" if ask == "Y"

        elsif yarn_lock_changed?
          say ""
          say "yarn.lock has changed."
          say ""
          say "Would you like to commit changes on yarn.lock ? [Yn]"
          run "git commit -m \"Update JS dependencies\" -- yarn.lock" if ask == "Y"
        end

        say ""
        say "List outdated JS dependencies"
        run "yarn outdated", abort_on_failure: false
      end

      protected

      def yarn_lock_changed?
        !run("git diff --quiet yarn.lock", abort_on_failure: false)
      end

      def package_changed?
        !run("git diff --quiet package.json", abort_on_failure: false)
      end
    end
  end
end
