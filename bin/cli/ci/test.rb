# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Test < Base
      def call(*args)
        args, options = parse_options!(*args, with: options_parser, arguments_expected: true)

        unless options[:"keep-coverage"]
          say "Clear previous coverage results"
          run "rm -rf coverage/.resultset.json"
          say ""
        end

        if args.empty?
          run_tests(:unit)
          run_tests(:system)
        else
          run_tests(*args)
        end
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} test [OPTIONS] [SCOPE|PATH]

          The command accepts a path (a *_spec.rb file) or one of the following scope:

              #{bin_prefix('ci')} test unit            Run unit tests (exclude system tests)
              #{bin_prefix('ci')} test system          Run system tests
              #{bin_prefix('ci')} test requests        Run requests tests
              #{bin_prefix('ci')} test components      Run components tests
              #{bin_prefix('ci')} test failed          Run only failed tests from previous run

          Options:

              --keep-coverage             Keep coverage results from previous runs and merge them
                                          into the report (used by `#{bin_prefix('ci')}` to sum up all scopes)
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--keep-coverage")
        end
      end

      def run_tests(*)
        scope, paths = parse_arguments(*)

        if scope != "failed"
          say "Run #{scope} specs"

          env     = build_env(scope)
          command = build_command(scope, paths)
          result  = run(command, env: env, abort_on_failure: false)
          return if result

          abort unless enable_retry?

          say "Cleanup database before retrying failed specs"
          run "bin/setup test #{parallel_mode ? '--parallel' : '--rspec'}"
        end

        say "Retry only failed specs"

        env     = build_env(scope, only_failures: true)
        command = build_command(scope, paths, only_failures: true)
        result  = run(command, env: env, abort_on_failure: false)

        abort unless result
      end

      SCOPES = {
        "unit"       => [],
        "system"     => %w[spec/system],
        "requests"   => %w[spec/requests],
        "components" => %w[spec/components]
      }.freeze

      def parse_arguments(*args)
        args = args.map(&:to_s)

        if args.empty?
          scope = "all"
          paths = []
        elsif args.size == 1 && SCOPES.include?(args[0])
          scope = args[0]
          paths = SCOPES[args[0]]
        elsif args.size == 1 && args[0] == "failed"
          scope = "failed"
          paths = []
        else
          scope = "given"
          paths = args
        end

        [scope, paths]
      end

      def build_env(scope, only_failures: false)
        env = {}

        env["PARALLEL_TEST_FIRST_IS_1"] = "true" if parallel_mode
        env["RSPEC_IGNORE_FOCUS"]       = "true"
        env["CI_LESS_OUTPUT"]           = "true" unless ENV.key?("CI_LESS_OUTPUT")

        if ENV["CI"] == "true"
          env["SIMPLE_COV"] = "false"
          env["SUPER_DIFF"] = "false"
          env["CAPYBARA_MAX_WAIT_TIME"] = "6"
        elsif ENV.fetch("SIMPLE_COV", "true") == "true" && !only_failures
          env["SIMPLE_COV"]         = "true"
          env["SIMPLE_COV_COMMAND"] = "bin/ci test"
          env["SIMPLE_COV_COMMAND"] += ":parallel" if parallel_mode
          env["SIMPLE_COV_COMMAND"] += ":#{scope}" if scope
        end

        env
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # I cannot make it simpler
      #
      def build_command(scope, paths, only_failures: false)
        if parallel_mode
          node_total = determine_number_of_parallel_processes(scope)
          node_index = ENV.fetch("CI_NODE_INDEX", nil)
        end

        @parallel_mode = nil if node_total == 1

        if parallel_mode == "parallel_rspec"
          rspec_options = []
          rspec_options += ["-f progress", "-f RSpec::Github::Formatter"] if ENV["CI"] == "true"
          rspec_options << "--only-failures" if only_failures

          command  = "bundle exec parallel_rspec"
          command += " -n #{node_total}"                if node_total
          command += " --only-group #{node_index}"      if node_index
          command += " --exclude-pattern spec/system"   if scope == "unit"
          command += " -- #{rspec_options.join(' ')} --" if rspec_options.any?

        else
          command  = "bundle exec rspec"
          command += " --exclude-pattern 'system/**/*_spec.rb'"                           if scope == "unit"
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

        runner =
          case ENV.fetch("CI_PARALLEL", nil)
          when "true", "parallel_rspec" then "parallel_rspec"
          when "false", nil             then nil
          else
            warn "CI_PARALLEL=#{ENV['CI_PARALLEL'].inspect} is not supported and ignored"
            nil
          end

        @parallel_mode = runner
      end

      def enable_retry?
        ENV.fetch("CI_ENABLE_RETRY", "false") == "true"
      end

      def determine_number_of_parallel_processes(scope)
        load_dotenv

        total = ENV.fetch("CI_NODE_TOTAL", nil)&.to_i
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
