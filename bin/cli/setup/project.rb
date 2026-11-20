# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class Project < Base
      def call(*)
        options    = parse_options!(*, with: options_parser, arguments_expected: false)
        setup_mode = options.fetch(:mode) { ask_setup_mode }

        unless options[:force]
          confirm_before_calling_destructive_method <<~MESSAGE

            You are about to drop and recreate all databases.
            All data will be lost !

          MESSAGE
        end

        run "bin/setup dependencies"
        run "bin/setup credentials --ignore-existing"
        run "bin/setup env --no-production"
        run "bin/setup databases --force --mode #{setup_mode}"
        run "bin/setup test"
        run "bin/setup submodules"

        say "Removing old logs and tempfiles"
        run "bin/rails log:clear tmp:clear"

        say ""
        say "✓ Application is ready!"
        say ""
        say "You might find these commands useful to complete your setup:"
        say ""
        say "    #{bin_prefix('setup')} user            # Create a new user through an interactive command"
        say "    #{bin_prefix('setup')} territories     # Import all EPCIs and communes from a remote source"
        say "    #{bin_prefix('setup')} hooks           # Setup git hooks to keep project up to date"
        say ""
      end

      def help
        say <<~MESSAGE
          Usage:

              #{bin_prefix('setup')} project [OPTIONS]

          Run the full setup process to prepare the Rails application:

              * Install dependencies: gems and JS packages
              * Check for Rails master key to unlock credentials
              * Check for usefull environnment variables
              * Reset development databases
              * Reset test databases
              * Precompile assets for system tests.
              * Initialize submodules

          It mostly depends on other commands from '#{bin_prefix('setup')}'
          The setup mode will be prompted to you on start.

          Available options:

            -f, --force                Bypass security warning and confirmation prompt
            -m, --mode <seed|empty>    Setup mode to reset database. A prompt will ask otherwise.
          \x5
        MESSAGE
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("-f",      "--force")
          parser.on("-m MODE", "--mode MODE", %w[seed empty])
        end
      end

      def ask_setup_mode
        say <<~MESSAGE
          How would you like to setup the database ?

            [s] seed the database
            [e] empty database
          \x5
        MESSAGE

        mode = loop do
          case ask
          when "s" then break "seed"
          when "e" then break "empty"
          end
        end

        say "You have selected #{mode} mode"
        say "(next time, use the option `--mode #{mode}` to skip this message)"
        say ""

        mode
      end
    end
  end
end
