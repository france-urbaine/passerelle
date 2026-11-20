# frozen_string_literal: true

require_relative "../base"
require_relative "../ci/watch"

module CLI
  module Setup
    class Test < Base
      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)
        steps   = select_steps(options)

        if steps.intersect?(%i[rspec parallel watch])
          setup_rspec    if steps.include?(:rspec)
          setup_parallel if steps.include?(:parallel)
          setup_watch    if steps.include?(:watch)

          say ""
          say "✓ Databases are ready for testing !"
          say ""
        end

        return unless steps.include?(:assets)

        setup_assets

        say ""
        say "✓ Assets are ready for testing !"
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} test [OPTIONS]

          Prepare your test suite.
          Without options provided, it performs all the following actions.

          Options:

              --rspec       Reset the test database used by RSpec
              --parallel    Reset all the test databases used to parallelize tests
              --watch       Reset the test database used by '#{bin_prefix('ci')} watch'
                            (skipped by default when CI=true)
              --assets      Precompile assets for system specs.
              --ci          Select the options required to run the full CI
                            (depending on parallel mode in .env.test)
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--rspec")
          parser.on("--parallel")
          parser.on("--watch")
          parser.on("--assets")
          parser.on("--ci")
        end
      end

      # Without options, perform all steps (except watch in CI environment).
      # The --ci option selects the steps required to run the full CI.
      #
      def select_steps(options)
        if options.empty?
          steps = %i[rspec parallel watch assets]
          steps.delete(:watch) if ENV["CI"] == "true"
          return steps
        end

        steps  = options.keys - [:ci]
        steps += %i[rspec assets]   if options[:ci]
        steps << :parallel          if options[:ci] && parallel_mode
        steps.uniq
      end

      def setup_rspec
        say "Setup test database"
        run "bin/rails db:test:prepare", env: { "RAILS_ENV" => "test" }
      end

      def setup_parallel
        say "Setup test databases for parallel testing"

        # FYI: We prefer the task 'parallel:load_schema' over 'parallel:prepare'
        # to bypass schema dumping
        #
        run "bin/rails parallel:load_schema", env: { "PARALLEL_TEST_FIRST_IS_1" => "true" }
      end

      def setup_watch
        if ENV.include?("POSTGRESQL_DATABASE")
          say "Setup test database for guard testing ignore due to presence of POSTGRESQL_DATABASE"
        else
          say "Setup test database for guard testing"
          run "bin/rails db:test:prepare", env: {
            "RAILS_ENV"           => "test",
            "POSTGRESQL_DATABASE" => CLI::CI::Watch::DEFAULT_DATABASE
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
