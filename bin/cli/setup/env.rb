# frozen_string_literal: true

require_relative "../base"
require "pathname"
require "dotenv"

module CLI
  class Setup
    class Env < Base
      def call
        say "Check for some basic environnement variables"

        setup_redis_sidekiq
        setup_redis_cache
        setup_smtp_port
        setup_ci_parallel
        setup_webdriver
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
        say "  [1-20]   Another database (redis://localhost:6379/{n})"
        say "  [Enter]  Use default URL  (redis://localhost:6379/0)"
        say ""

        value = ask
        value = 0 unless (1..20).cover?(value.to_i)

        add_variable "REDIS_SIDEKIQ_URL", "redis://localhost:6379/#{value}", ".env.development"
      end

      def setup_redis_cache
        return if variable_exist?("REDIS_CACHE_URL", ".env.development")

        say ""
        say "Would you like to set a dedicated Redis database for caching ?"
        say ""
        say "  [1-20]   Another database (redis://localhost:6379/{n})"
        say "  [Enter]  Use default URL  (redis://localhost:6379/1)"
        say ""

        value = ask
        value = 1 unless (1..20).cover?(value.to_i)

        add_variable "REDIS_CACHE_URL", "redis://localhost:6379/#{value}", ".env.development"
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
        value = 1025 if value.empty?

        add_variable "SMTP_PORT", value, ".env.development"
      end

      def setup_ci_parallel
        return if variable_exist?("CI_PARALLEL", ".env.test")

        say ""
        say "Would you like to run CI in parallel ?"
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

      def setup_webdriver
        return if variable_exist?("WEBDRIVER", ".env.test")

        say ""
        say "Would you like to use Chrome (or Chromium) to run system tests ? [Yn]"

        if ask == "Y"
          add_variable "WEBDRIVER", "cuprite", ".env.test"
        else
          say "Please enter your preferred webdriver:"
          say "  example: firefox_headless"

          webdriver = ask_variable("WEBDRIVER")

          say ""
          add_variable "WEBDRIVER", webdriver, ".env.test"
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

        if ask != "Y"
          run "touch .env.production"
          return
        end

        pg_host       = ask_variable("POSTGRESQL_HOST")
        pg_port       = ask_variable("POSTGRESQL_PORT")
        pg_database   = ask_variable("POSTGRESQL_DATABASE")
        pg_user       = ask_variable("POSTGRESQL_USER")
        pg_password   = ask_variable("POSTGRESQL_PASSWORD", secret: true)

        say ""
        add_variable "POSTGRESQL_HOST",     pg_host,     ".env.production"
        add_variable "POSTGRESQL_PORT",     pg_port,     ".env.production"
        add_variable "POSTGRESQL_DATABASE", pg_database, ".env.production"
        add_variable "POSTGRESQL_USER",     pg_user,     ".env.production"
        add_variable "POSTGRESQL_PASSWORD", pg_password, ".env.production"

        say ""
        sidekiq_url = ask_variable("REDIS_SIDEKIQ_URL")
        cache_url   = ask_variable("REDIS_CACHE_URL")

        say ""
        add_variable "REDIS_SIDEKIQ_URL", sidekiq_url, ".env.production"
        add_variable "REDIS_CACHE_URL",   cache_url,   ".env.production"
      end

      private

      def file(file)
        Pathname.new(__dir__).join("../../../", file)
      end

      def variable_exist?(variable, file)
        path = file(file)
        return false unless path.exist?

        vars = Dotenv.parse(path)
        vars.include?(variable) && !vars[variable].empty?
      end

      def file_exist?(file)
        path = file(file)
        path.exist?
      end

      def ask_variable(variable, **)
        ask("  > #{variable} = ", loop_empty: true, end_say: nil, **).strip
      end

      def add_variable(variable, value, file)
        output = "#{variable}="
        output << format_variable_value(value)

        say "  => puts `#{output}` in #{file}"

        FileUtils.touch(file)

        file(file).open("r+") do |f|
          lines = f.readlines
          lines.last << $RS unless lines.last.nil? || lines.last.end_with?($RS)
          lines << output << $RS

          f.rewind
          f.write lines.join
        end
      end

      def format_variable_value(value)
        case value
        when /^\d+$/, true, false
          value.to_s
        else
          %("#{value}")
        end
      end
    end
  end
end
