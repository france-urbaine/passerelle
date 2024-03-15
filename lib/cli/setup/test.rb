# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Test < Base
      def call(arguments: ARGV)
        subjects =
          if arguments.any?
            arguments
          else
            %w[rspec parallel watch assets].tap do |array|
              array.delete("watch") if ENV["CI"] == "true"
            end
          end

        if subjects.include?("rspec")
          say "Setup test database"
          run "bin/rails db:test:prepare", env: { "RAILS_ENV" => "test" }
        end

        if subjects.include?("parallel")
          say "Setup test databases for parallel testing"
          run "bin/rails parallel:prepare", env: { "PARALLEL_TEST_FIRST_IS_1" => "true" }
        end

        if subjects.include?("watch")
          if ENV.include?("POSTGRESQL_DATABASE")
            say "Setup test database for guard testing ignore due to presence of POSTGRESQL_DATABASE"
          else
            say "Setup test database for guard testing"
            run "bin/rails db:test:prepare", env: {
              "RAILS_ENV"           => "test",
              "POSTGRESQL_DATABASE" => "passerelle_test_watch"
            }
          end
        end

        if subjects.include?("assets")
          # Compile assets in case they were missing.
          # They are required to start the test suite
          say "Compile assets to run system tests"
          run "yarn build:css"
          run "yarn build:js"
        end

        say ""
        say "✓ You're ready to launch the CI !"
        say ""
      end
    end
  end
end
