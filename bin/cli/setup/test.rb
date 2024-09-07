# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Test < Base
      def call(*args)
        subjects = parse_subjects(args)

        setup_rspec     if subjects.include?("rspec")
        setup_parallel  if subjects.include?("parallel")
        setup_watch     if subjects.include?("watch")
        setup_assets    if subjects.include?("assets")

        say ""
        say "✓ You're ready to launch the CI !"
        say ""
      end

      def setup_rspec
        say "Setup test database"
        run "bin/rails db:test:prepare", env: { "RAILS_ENV" => "test" }
      end

      def setup_parallel
        say "Setup test databases for parallel testing"

        if parallel_mode == "flatware"
          run "bundle exec flatware fan rake db:test:prepare"
        else
          run "bin/rails parallel:prepare", env: { "PARALLEL_TEST_FIRST_IS_1" => "true" }
        end
      end

      def setup_watch
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

      def setup_assets
        # Compile assets in case they were missing.
        # They are required to start the test suite
        say "Compile assets to run system tests"
        run "yarn build:css"
        run "yarn build:js"
      end

      protected

      def parse_subjects(subjects)
        return subjects if subjects.any?

        %w[rspec parallel watch assets].tap do |array|
          array.delete("watch") if ENV["CI"] == "true"
        end
      end

      def parallel_mode
        @parallel_mode ||= begin
          begin
            require "dotenv"
            Dotenv.load(".env.test")
          rescue LoadError
            # Do nothing
          end

          parallel = ENV.fetch("CI_PARALLEL", nil)
          parallel = nil if parallel == "false"
          parallel
        end
      end
    end
  end
end
