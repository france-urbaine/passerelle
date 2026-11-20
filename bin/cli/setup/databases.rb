# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class Databases < Base
      def call(*)
        options    = parse_options!(*, with: options_parser, arguments_expected: false)
        setup_mode = options.fetch(:mode, "seed")

        unless options[:force]
          confirm_before_calling_destructive_method <<~MESSAGE

            You are about to drop and recreate all databases.
            All data will be lost !

          MESSAGE
        end

        say "Drop & recreate the development and test databases"
        run "bin/rails db:purge"
        run "bin/rails db:schema:load"

        if setup_mode == "seed"
          say "Seed database"
          run "bin/rails db:seed", env: { "SETUP_SEED" => "true" }
        end

        say ""
        say "✓ Postgres database is ready."
        say ""

        say "Clear Redis databases"
        run "bin/rails sidekiq:flushdb"
        run "bin/rails cache:clear"

        say ""
        say "✓ Redis databases are ready."
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} databases [OPTIONS]

          Reset all the databases used in development environment:

              * Postgres
              * Redis

          You can specify an option to seed data or keep the database empty.

          Options:

              -f, --force                Bypass security warning and confirmation prompt
              -m, --mode <seed|empty>    Setup mode to reset database. Default to 'seed'.
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("-f",      "--force")
          parser.on("-m MODE", "--mode MODE", %w[seed empty])
        end
      end
    end
  end
end
