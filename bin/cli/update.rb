# frozen_string_literal: true

require_relative "base"

module CLI
  class Update < Base
    def call(arg)
      arg.nil? ? check : help
    end

    def help
      say <<~HEREDOC
        Update commands:

            bin/update          # Check for changes on dependencies, submodules and database

        To add bin/update to your git hooks, run:

            bin/setup githooks
        \x5
      HEREDOC
    end

    def check
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
  end
end
