# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Test < Base
      SCOPES = %w[
        unit
        system
      ].freeze

      def call(arguments: ARGV)
        if arguments.empty?
          paths = []
          say "Running all tests"
        elsif SCOPES.include?(arguments[0])
          scope = arguments[0]
          paths = []
          say "Running #{scope} tests"
        else
          paths = arguments
          say "Running given tests"
        end

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
end
