# frozen_string_literal: true

require_relative "base"

module CLI
  class Update < Base
    def call(arguments: ARGV)
      case arguments[0]
      when nil      then update_check
      when "bundle" then update_bundle
      when "yarn"   then update_yarn
      when "icons"  then update_icons
      else               help
      end
    end

    def help
      say <<~HEREDOC
        Update commands:

            #{program_name}         # Check for changes on dependencies, submodules and database
            #{program_name} bundle  # Update gems through an interactive command
            #{program_name} yarn    # Update JS packages through an interactive command
            #{program_name} icon    # Update icons sets (heroicons)"
            #{program_name} help    # Show this help

        To add bin/update to your git hooks, run:

            bin/setup githooks
        \x5
      HEREDOC
    end

    def update_check
      say "Verifying gem dependencies"
      run "bundle check || bundle install"

      say "Verifying JS packages"
      run "yarn"

      say "Verifying submodule"
      run "git submodule init"
      run "git submodule update"

      say "Verifying database migration"
      run "bin/rails db:migrate"
    end

    def update_bundle
      say "Updating gems"
      results = perform_gems_update

      if results.any? { |gem| gem.include?("rubocop") }
        say "Some rubocop gems have been updated."
        say "Stopping rubocop server"
        run "rubocop --stop-server", abort_on_failure: false
      end

      say ""
      say "List outdated gems"
      run "bundle outdated", abort_on_failure: false

      say "No outdated gems" if run_succeed?
      say ""
      say "Press [Enter] to continue"
      ask

      if results.any?
        say ""
        say "Some gems have been updated."
        say "Would you like to run the CI ? [Yn]"
        run "bin/ci" if ask == "Y"
      end

      if gemfile_lock_changed?
        say ""
        say "Gemfile.lock has changed."
        say "Would you like to commit changes to Gemfile.lock ? [Yn]"
        run "git commit -m \"Update gems dependencies\" -- Gemfile.lock" if ask == "Y"
      else
        say "No changes to commit."
      end
    end

    def update_yarn
      say "Updating JS dependencies"
      run "yarn upgrade-interactive --latest"

      say ""
      say "List outdated JS dependencies"
      run "yarn outdated", abort_on_failure: false

      say "No outdated packages" if run_succeed?
      say ""
      say "Press [Enter] to continue"
      ask

      if package_changed? && yarn_lock_changed?
        say "package.json & yarn.lock have changed."
        say "Would you like to see changes on package.json ? [Yn]"
        run "git diff package.json" if ask == "Y"

        say "Would you like to commit changes on yarn.lock & package.json ? [Yn]"
        run "git commit -m \"Update JS dependencies\" -- package.json yarn.lock" if ask == "Y"
      elsif yarn_lock_changed?
        say "yarn.lock has changed."
        say "Would you like to commit changes on yarn.lock ? [Yn]"
        run "git commit -m \"Update JS dependencies\" -- yarn.lock" if ask == "Y"
      end
    end

    def update_icons
      say "Updating Heroicons set"
      run "git submodule update --remote vendor/submodules/heroicons"
    end

    protected

    def perform_gems_update
      require "bundler/setup"
      require "bundleup"

      bundleup = Bundleup::CLI.new([])
      bundleup.run
      bundleup.updated_gems
    end

    def gemfile_lock_changed?
      !run("git diff --quiet Gemfile.lock", abort_on_failure: false)
    end

    def yarn_lock_changed?
      !run("git diff --quiet yarn.lock", abort_on_failure: false)
    end

    def package_changed?
      !run("git diff --quiet package.json", abort_on_failure: false)
    end
  end
end
