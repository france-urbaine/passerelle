# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Factories < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Running FactoryBot linter"
        run "bundle exec bin/rails factory_bot:lint", env: { "RAILS_ENV" => "test" }
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} factories

          A command script to lint factories from FactoryBot
          \x5
        HEREDOC
      end
    end
  end
end
