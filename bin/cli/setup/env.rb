# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  module Setup
    class Env < Base
      def call(*)
        options    = parse_options!(*, with: options_parser, arguments_expected: false)
        production = options.fetch(:production, false)

        require "dotenv"

        if production
          setup_production
        else
          say "Check for some basic environnement variables"
          setup_ci_parallel
          setup_super_diff
        end

        say ""
        say "✓ All environnement variables are ready !"
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} env [OPTIONS]

          Check if usefull environment variables have been defined in .env files.
          Prompt user about missing ones.

          Options:

              --[no-]production    Check for production variables. Excluded by default.
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--[no-]production")
        end
      end

      def setup_ci_parallel
        return if variable_exist?("CI_PARALLEL", ".env.test")

        say ""
        say "Would you like to run CI in parallel ?"
        say ""
        say "  [0] No (default)"
        say "  [1] Use parallel_tests"
        say ""

        case ask
        when "1" then add_variable "CI_PARALLEL", true, ".env.test"
        end
      end

      def setup_super_diff
        return if variable_exist?("SUPER_DIFF", ".env.test")

        say ""
        say "Would you like to use SuperDiff ? [Yn]"

        add_variable "SUPER_DIFF", (ask == "Y"), ".env.test"
      end

      def setup_production
        if file_exist?(".env.production")
          say "The file #{colorize('.env.production', :YELLOW, :BOLD)} already exist."
          say "Would you like to delete it to continue ? [Yn]"
          exit if ask != "Y"

          run "rm .env.production"
        end

        run "touch .env.production"

        say ""
        say "The file #{colorize('.env.production', :YELLOW, :BOLD)} has been created."
        say "If you interrupt this process, it will not prompt you anymore."
        say "You may first delete the file to use the prompt again."
        say ""

        say "Configure access to Postgres."
        say ""

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
        say "Configure access to Redis."
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

      # Variables already provided by the environment (e.g. by docker-compose)
      # take precedence over .env files: no need to ask for them.
      #
      def variable_exist?(variable, file)
        return true if ENV[variable] && !ENV[variable].empty?

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
