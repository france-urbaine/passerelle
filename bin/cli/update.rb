# frozen_string_literal: true

require_relative "base"

module CLI
  class Update < Base
    def call(*)
      parse_options!(*, arguments_expected: false)

      say "Verifying dependencies"
      run "bin/setup dependencies"

      say "Verifying submodule"
      run "bin/setup submodules"

      run "bin/setup env"

      say "Verifying database migration"
      run "QUICK_MIGRATION_UPDATE=true bin/rails db:migrate"

      say ""
      say "✓ Environment up to date !"
      say ""
    end

    def help
      say <<~HEREDOC
        Usage:

            #{bin_prefix('update')}

        A command script to update dependencies, submodules and databases states.
        To add bin/update to your git hooks, run:

            #{bin_prefix('setup')} hooks

        If you want to upgrade dependencies, you should take look at:

            #{bin_prefix('upgrade')} --help
        \x5
      HEREDOC
    end
  end
end
