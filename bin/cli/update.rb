# frozen_string_literal: true

require_relative "base"

module CLI
  class Update < Base
    def call(*arg)
      arg.empty? ? check : help
    end

    def help
      say <<~HEREDOC
        Update commands:

            bin/update          # Check for changes on dependencies, submodules and database

        To add bin/update to your git hooks, run:

            bin/setup githooks

        If you want to upgrade dependencies, you should take look at:

            bin/upgrade help
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

      run "bin/setup env"

      say "Verifying database migration"
      run "ANNOTATERB_SKIP_ON_DB_TASKS=1 DUMP_SCHEMA_AFTER_MIGRATION=false bin/rails db:migrate"
    end
  end
end
