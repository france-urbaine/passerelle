# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class Env < Base
      def call
        say "Check for some basic environnement variables"

        setup_smtp_port
        setup_ci_parallel
        setup_production

        say ""
        say "✓ All environnement variables are ready !"
        say ""
      end

      def setup_smtp_port
        return if variable_exist?("SMTP_PORT", ".env.development")

        say ""
        say "Would you like to set an other port to use with MailCacther ? (default is 1025)"

        value = ask
        return if value.empty?

        add_variable "SMTP_PORT", value, ".env.development"
      end

      def setup_ci_parallel
        return if variable_exist?("CI_PARALLEL", ".env.test")

        say ""
        say "Would you like to run CI in parallel ? (default is no)"
        say "  [0] No (default)"
        say "  [1] Use parallel_tests"
        say "  [2] Use turbo_tests"
        say "  [3] Use flatware"

        case ask
        when "1" then add_variable "CI_PARALLEL", true,          ".env.test"
        when "2" then add_variable "CI_PARALLEL", "turbo_tests", ".env.test"
        when "3" then add_variable "CI_PARALLEL", "flatware",    ".env.test"
        end
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
        ].each_with_object({}) do |variable, hash|
          hash[variable] = ask(
            "  #{variable} > ",
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
          when /^[\d\w]+$/, true then value.to_s
          else %("#{value}").to_s
          end

        say "=> puts `#{output}` in #{file}"

        file(file).open("a+") do |f|
          f.puts output
        end
      end
    end
  end
end
