# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class Env < Base
      def call
        say "Check for some basic environnement variables"

        setup_redis_sidekiq
        setup_smtp_port
        setup_ci_parallel
        setup_super_diff
        setup_production

        say ""
        say "✓ All environnement variables are ready !"
        say ""
      end

      def setup_redis_sidekiq
        return if variable_exist?("REDIS_SIDEKIQ_URL", ".env.development")

        say ""
        say "Would you like to set a dedicated Redis database for Sidekiq ?"
        say ""
        say "  [0]    No (default to redis://localhost:6379)"
        say "  [1-20] Another database (redis://localhost:6379/{database})"
        say ""

        value = ask
        return unless (1..20).cover?(value.to_i)

        add_variable "REDIS_SIDEKIQ_URL", "redis://localhost:6379/#{value}", ".env.development"
      end

      def setup_smtp_port
        return if variable_exist?("SMTP_PORT", ".env.development")

        say ""
        say "Would you like to set a custom port to use with MailCacther ?"
        say ""
        say "  [any integer] Use custom port"
        say "  [nothing]     Use default port (1025)"
        say ""

        value = ask
        return if value.empty?

        add_variable "SMTP_PORT", value, ".env.development"
      end

      def setup_ci_parallel
        return if variable_exist?("CI_PARALLEL", ".env.test")

        say ""
        say "Would you like to run CI in parallel ? (default is no)"
        say ""
        say "  [0] No (default)"
        say "  [1] Use parallel_tests"
        say "  [2] Use turbo_tests       (experimental, better output)"
        say "  [3] Use flatware          (experimental, faster)"
        say ""

        case ask
        when "1" then add_variable "CI_PARALLEL", true,          ".env.test"
        when "2" then add_variable "CI_PARALLEL", "turbo_tests", ".env.test"
        when "3" then add_variable "CI_PARALLEL", "flatware",    ".env.test"
        end
      end

      def setup_super_diff
        return if variable_exist?("SUPER_DIFF", ".env.test")

        say ""
        say "Would you like to use SuperDiff ? [Yn]"

        add_variable "SUPER_DIFF", (ask == "Y"), ".env.test"
      end

      def setup_production
        return if file_exist?(".env.production")

        say ""
        say "Would you like to set up a production environnement ? [Yn]"
        return unless ask == "Y"

        vars = %w[
          POSTGRESQL_HOST
          POSTGRESQL_PORT
          POSTGRESQL_DATABASE
          POSTGRESQL_USER
          POSTGRESQL_PASSWORD
          REDIS_SIDEKIQ_URL
          REDIS_CACHE_URL
        ].each_with_object({}) do |variable, hash|
          hash[variable] = ask(
            "  > #{variable} = ",
            loop_empty: true,
            end_say:    nil
          )
        end

        say ""
        vars.each do |variable, value|
          add_variable variable, value, ".env.production"
        end
      end

      private

      def file(file)
        Pathname.new(__dir__).join("../../../", file)
      end

      def variable_exist?(variable, file)
        path = file(file)
        path.exist? && path.read.include?(variable)
      end

      def file_exist?(file)
        path = file(file)
        path.exist?
      end

      def add_variable(variable, value, file)
        output = "#{variable}="
        output <<
          case value
          when /^\d+$/, true, false
            value.to_s
          else
            %("#{value}").to_s
          end

        say "  => puts `#{output}` in #{file}"

        file(file).open("a+") do |f|
          lines = f.readlines

          f.puts if lines.any? && !lines.last.end_with?("\n")
          f.puts output
        end
      end
    end
  end
end
