# frozen_string_literal: true

require_relative "base"

module CLI
  class CI < Base
    def call(arguments: ARGV)
      case arguments[0]
      when nil              then run_all
      when "watch"          then watch
      when "factories"      then lint_factories
      when /test(?::(.*))?/ then test(Regexp.last_match[1], arguments[1..])
      when "rubocop"        then rubocop(arguments[1..])
      when "brakeman"       then brakeman
      when "audit"          then audit
      else                       help
      end
    end

    def help
      say <<~HEREDOC
        CI commands:

            #{program_name}               # Run all tests and checks as CI would
            #{program_name} watch         # Watch & run CI checks from GuardFile as code change
            #{program_name} help          # Show this help

        You can also run only one program from the CI:

            #{program_name} factories     # Lint test factories
            #{program_name} test          # Run all the test suite
            #{program_name} test:unit     # Run non-system tests
            #{program_name} test:system   # Run system tests
            #{program_name} rubocop       # Analyzing code issues with Rubocop
            #{program_name} brakeman      # Analyzing code for security vulnerabilities.
            #{program_name} audit         # Analyzing ruby gems for security vulnerabilities

        To run tests in parallel, define the CI_PARALLEL environnment variable with one of the following values:

            CI_PARALLEL=true              # Use parallel_tests
            CI_PARALLEL=turbo_tests       # Use turbo_tests (experimental, better output)
            CI_PARALLEL=flatware          # Use flatware    (experimental, faster, less options)

        To run the commands in CI environnement (ex: on Github), use the CI variable:

            CI=true #{program_name}
        \x5
      HEREDOC
    end

    def run_all
      lint_factories
      clear_coverage
      test("unit")
      test("system")
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

    TEST_SCOPES = %w[
      unit
      system
    ].freeze

    def test(scope = nil, paths = [])
      raise ArgumentError, "unknown command `bin/ci test:#{scope}`" unless scope.nil? || TEST_SCOPES.include?(scope)

      say "Running tests"
      clear_coverage unless @coverage_cleared

      env     = test_env(scope)
      command = test_command(scope, paths)

      run command, env: env
    end

    def test_env(scope)
      env = { "SIMPLE_COV_COMMAND" => "bin/ci test" }
      env["SIMPLE_COV_COMMAND"] += ":parallel" if parallel
      env["SIMPLE_COV_COMMAND"] += ":#{scope}" if scope
      env["PARALLEL_TEST_FIRST_IS_1"] = "true" if parallel && parallel != "flatware"
      env["RSPEC_IGNORE_FOCUS"] = "true"

      if ENV["CI"] == "true"
        env["SIMPLE_COV"] = "false"
        env["SUPER_DIFF"] = "false"
        env["CAPYBARA_MAX_WAIT_TIME"] = "6"
      end

      env
    end

    # I cannot make it simpler
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    #
    def test_command(scope, paths)
      if parallel
        node_total = determine_number_of_parallel_processes(scope)
        node_index = ENV.fetch("CI_NODE_INDEX", nil)
      end

      if parallel == "turbo_tests" && ENV["CI"] != "true"
        command  = "bundle exec turbo_tests"
        command += " -n #{node_total}"              if node_total
        command += " --only-group #{node_index}"    if node_index
        command += " --exclude-pattern spec/system" if scope == "unit"
        command += " --pattern spec/system"         if scope == "system"
        command += " -f Fuubar"
      elsif parallel == "flatware" && ENV["CI"] != "true"
        command  = "bundle exec flatware rspec"
        command += " -w #{node_total}"                                                  if node_total
        warn "CI_NODE_INDEX is ignored when using flatware for parallel testing"        if node_index
        command += " --exclude-pattern 'system/**/*_spec.rb'"                           if scope == "unit"
        command += " --pattern 'system/**/*_spec.rb'"                                   if scope == "system"
      elsif parallel
        command  = "bundle exec parallel_rspec"
        command += " -n #{node_total}"                                                  if node_total
        command += " --only-group #{node_index}"                                        if node_index
        command += " --exclude-pattern spec/system"                                     if scope == "unit"
        command += " --pattern spec/system"                                             if scope == "system"
        command += " -- -f progress -f RSpec::Github::Formatter --"                     if ENV["CI"] == "true"
      else
        command  = "bundle exec rspec"
        command += " --exclude-pattern 'system/**/*_spec.rb'"                           if scope == "unit"
        command += " --pattern 'system/**/*_spec.rb'"                                   if scope == "system"
        command += " --no-profile --format RSpec::Github::Formatter --format progress"  if ENV["CI"] == "true"
      end

      command += " #{paths.join(' ')}" if paths.any?
      command
    end
    #
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def rubocop(paths = [])
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

    private

    def parallel
      @parallel ||= begin
        load_dotenv
        parallel = ENV.fetch("CI_PARALLEL", nil)
        parallel = nil if parallel == "false"
        parallel
      end
    end

    def determine_number_of_parallel_processes(scope)
      load_dotenv

      total = ENV.fetch("CI_NODE_TOTAL", nil)
      total = 2 if scope == "system" && (total.nil? || total > 2)
      total
    end

    def load_dotenv
      return if @dotenv_loaded

      require "dotenv"
      Dotenv.load(".env.test")
    rescue LoadError
      # Do nothing
    ensure
      @dotenv_loaded = true
    end
  end
end
