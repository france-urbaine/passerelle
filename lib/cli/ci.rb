# frozen_string_literal: true

require_relative "base"

module CLI
  class CI < Base
    def call(arguments: ARGV)
      case arguments[0]
      when nil          then run_all
      when "watch"      then watch
      when "factories"  then lint_factories
      when "test"       then test(*arguments[1..])
      when /test:.+/    then legacy_test(*arguments)
      when "rubocop"    then rubocop(*arguments[1..])
      when "brakeman"   then brakeman
      when "audit"      then audit
      else                   help
      end
    end

    def help
      say <<~HEREDOC
        CI commands:

            #{program_name}                     # Run all tests and checks as CI would
            #{program_name} watch               # Watch & run CI checks from GuardFile as code change
            #{program_name} help                # Show this help

        You can also run only one program from the CI:

            #{program_name} factories           # Lint test factories
            #{program_name} test                # Run all the test suite
            #{program_name} rubocop             # Analyzing code issues with Rubocop
            #{program_name} brakeman            # Analyzing code for security vulnerabilities.
            #{program_name} audit               # Analyzing ruby gems for security vulnerabilities

        When running tests, you can provide one of the following scope or some paths

            #{program_name} test unit           # Run unit tests
            #{program_name} test system         # Run system tests
            #{program_name} test [path]         # ex: `#{program_name} test spec/models`

        To run tests in parallel, define the CI_PARALLEL environnment variable with one of the following values:

            CI_PARALLEL=true           # Use parallel_tests
            CI_PARALLEL=turbo_tests    # Use turbo_tests (experimental, better output)
            CI_PARALLEL=flatware       # Use flatware    (experimental, faster, less options)

        To run the commands in CI environnement (ex: on Github), use the CI variable:

            CI=true #{program_name}
        \x5
      HEREDOC
    end

    def run_all
      lint_factories
      clear_coverage
      test("unit")
      test("system", "--retry-failures")
      rubocop
      brakeman
      audit

      say ""
      say "✓ All done !"
      say ""
    end

    def lint_factories
      say "Running FactoryBot linter"
      run "bundle exec bin/rails factory_bot:lint", env: { "RAILS_ENV" => "test" }
    end

    def clear_coverage
      say "Clear previous coverage results"
      run "rm -rf coverage/.resultset.json"

      @coverage_cleared = true
    end

    def test(*args)
      require_relative "ci/test"

      clear_coverage unless @coverage_cleared
      CLI::CI::Test.new(program_name).call(arguments: args)
    end

    def legacy_test(*args)
      new_args = args.join(" ").gsub(/test:(.+)/, "test \\1")

      say <<~MESSAGE
        This command is deprecated.
        Instead, you should try:

            #{program_name} #{new_args}

        To learn more about comamnds, try:

            #{program_name} help
        \x5
      MESSAGE

      abort
    end

    def rubocop(*paths)
      say "Analyzing code issues with Rubocop"

      command = "bundle exec rubocop"
      command += " --server --display-cop-names" unless ENV["CI"] == "true"
      command += " #{paths.join(' ')}" if paths.any?

      run command
    end

    def brakeman
      say "Analyzing code for security vulnerabilities"
      run "bundle exec brakeman --color -o /dev/stdout -o tmp/brakeman.html"
    end

    def audit
      say "Analyzing ruby gems for security vulnerabilities"
      run "bundle exec bundle audit check --update"
    end

    def watch
      say "Starting Guard"

      env = {}
      env["POSTGRESQL_DATABASE"] = ENV.fetch("POSTGRESQL_DATABASE", "passerelle_test_watch")
      env["LOG_PATH"]            = ENV.fetch("LOG_PATH", "log/watch.log")
      env["SKIP_ALL_ON_START_WARNING"] = "true"

      run "bundle exec guard", env: env
    end
  end
end
