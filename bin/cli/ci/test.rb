# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Test < Base
      def call(*args)
        say "Clear previous coverage results"
        run "rm -rf coverage/.resultset.json"
        say ""

        if parallel_mode == "flatware"
          say "Clear flatware processes & sink"
          run "flatware clear"
          run "rm -f flatware-sink"
          say ""
        end

        if args.empty?
          run_tests(:unit)
          run_tests(:system)
        else
          run_tests(*args)
        end
      end

      def run_tests(*)
        scope, paths = parse_arguments(*)

        say "Run #{scope} specs"

        env     = build_env(scope)
        command = build_command(scope, paths)
        result  = run(command, env: env, abort_on_failure: false)

        unless result
          say "Retry only failed specs"
          command = build_command(scope, paths, only_failures: true)
          result  = run(command, env: env, abort_on_failure: false)
        end

        abort unless result
      end

      SCOPES = {
        "unit"       => [],
        "system"     => [],
        "components" => %w[spec/components],
        "requests"   => %w[spec/requests]
      }.freeze

      def parse_arguments(*args)
        args = args.map(&:to_s)

        if args.empty?
          scope = "all"
          paths = []
        elsif args.size == 1 && SCOPES.include?(args[0])
          scope = args[0]
          paths = SCOPES[args[0]]
        else
          scope = "given"
          paths = args
        end

        [scope, paths]
      end

      def build_env(scope)
        env = { "SIMPLE_COV_COMMAND" => "bin/ci test" }
        env["SIMPLE_COV_COMMAND"] += ":parallel" if parallel_mode
        env["SIMPLE_COV_COMMAND"] += ":#{scope}" if scope
        env["PARALLEL_TEST_FIRST_IS_1"] = "true" if parallel_mode && parallel_mode != "flatware"
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
      def build_command(scope, paths, only_failures: false)
        if parallel_mode
          node_total = determine_number_of_parallel_processes(scope)
          node_index = ENV.fetch("CI_NODE_INDEX", nil)
        end

        @parallel_mode = nil if node_total == 1

        if parallel_mode == "turbo_tests" && !only_failures
          command  = "bundle exec turbo_tests"
          command += " -n #{node_total}" if node_total
          command += " -r fuubar -f Fuubar"
          command += " --"                            if node_index || scope
          command += " --only-group #{node_index}"    if node_index
          command += " --exclude-pattern spec/system" if scope == "unit"
          command += " --pattern spec/system"         if scope == "system"

        elsif parallel_mode == "flatware"
          command  = "bundle exec flatware rspec"
          command += " -w #{node_total}"                                                  if node_total
          warn "CI_NODE_INDEX is ignored when using flatware for parallel testing"        if node_index
          command += " --exclude-pattern 'system/**/*_spec.rb'"                           if scope == "unit"
          command += " --pattern 'system/**/*_spec.rb'"                                   if scope == "system"
          command += " --only-failures"                                                   if only_failures

        elsif parallel_mode && !only_failures
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
          command += " --only-failures"                                                   if only_failures
        end

        command += " #{paths.join(' ')}" if paths.any?
        command
      end
      #
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      private

      def parallel_mode
        return @parallel_mode if defined?(@parallel_mode)

        load_dotenv
        parallel = ENV.fetch("CI_PARALLEL", nil)
        parallel = nil  if parallel == "false"

        # Do not use flatware or turbo_tests in CI mode.
        parallel = true if parallel && ENV["CI"] == "true"

        @parallel_mode = parallel
      end

      def determine_number_of_parallel_processes(scope)
        load_dotenv

        total = ENV.fetch("CI_NODE_TOTAL", nil)
        total = 2 if scope == "system" && (total.nil? || total > 2)
        total = 1 if scope == "system" && system_spec_files.size == 1
        total
      end

      def system_spec_files
        Dir[File.join(File.expand_path("../../../spec/system", __dir__), "**/*_spec.rb")]
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
end
