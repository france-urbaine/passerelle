# frozen_string_literal: true

require_relative "base"

module CLI
  class CI < Base
    def call(*args)
      case args[0]
      when nil          then run_all
      when "watch"      then CLI::CI::Watch.call(*args[1..])
      when "factories"  then CLI::CI::Factories.call
      when "test"       then CLI::CI::Test.call(*args[1..])
      when "rubocop"    then CLI::CI::Rubocop.call(*args[1..])
      when "brakeman"   then CLI::CI::Brakeman.call(*args[1..])
      when "audit"      then CLI::CI::Audit.call
      else help
      end
    end

    def help
      say <<~HEREDOC
        CI commands:

            bin/ci                     # Run all tests and checks as CI would
            bin/ci watch               # Watch & run CI programs whenever file are modified
            bin/ci help                # Show this help

        You can also run only one program from the CI:

            bin/ci factories           # Lint test factories
            bin/ci test                # Run all the test suite
            bin/ci rubocop             # Analyzing code issues with Rubocop
            bin/ci brakeman            # Analyzing code for security vulnerabilities.
            bin/ci audit               # Analyzing ruby gems for security vulnerabilities

        When running tests, you can provide one of the following scope or some paths

            bin/ci test unit           # Run unit tests
            bin/ci test system         # Run system tests
            bin/ci test requests       # Run requests tests
            bin/ci test components     # Run components tests
            bin/ci test [path]         # ex: `bin/ci test spec/models`

        Watch accepts a plugin as argument:

            bin/ci watch rspec         # Watch and run only RSpec
            bin/ci watch rubocop       # Watch and run only Rubocop
            bin/ci watch factories     # Watch and run only FactoryBot linter

        To run tests in parallel, define the CI_PARALLEL environnment variable with one of the following values:

            CI_PARALLEL=true           # Use parallel_tests
            CI_PARALLEL=turbo_tests    # Use turbo_tests (experimental, better output)
            CI_PARALLEL=flatware       # Use flatware    (experimental, faster)

        To run the commands in CI environnement (ex: on Github), use the CI variable:

            CI=true bin/ci
        \x5
      HEREDOC
    end

    def run_all
      run "bin/ci factories"
      run "bin/ci test"
      run "bin/ci rubocop"
      run "bin/ci audit"
      run "bin/ci brakeman"

      say ""
      say "✓ All good !"
      say ""
    end
  end
end
