# frozen_string_literal: true

require_relative "base"
require_relative "setup/credentials"
require_relative "setup/databases"
require_relative "setup/dependencies"
require_relative "setup/env"
require_relative "setup/hooks"
require_relative "setup/project"
require_relative "setup/submodules"
require_relative "setup/territories"
require_relative "setup/test"
require_relative "setup/user"

module CLI
  module Setup
    def self.run = Default.run

    class Default < Base
      # rubocop:disable Metrics/CyclomaticComplexity
      # Rubocop found it complex because of one long case/when statement.
      #
      def call(command = nil, *)
        raise_on_production!

        case command
        when "project"      then CLI::Setup::Project.call(*)
        when "dependencies" then CLI::Setup::Dependencies.call(*)
        when "credentials"  then CLI::Setup::Credentials.call(*)
        when "env"          then CLI::Setup::Env.call(*)
        when "databases"    then CLI::Setup::Databases.call(*)
        when "test"         then CLI::Setup::Test.call(*)
        when "submodules"   then CLI::Setup::Submodules.call(*)
        when "user"         then CLI::Setup::User.call(*)
        when "territories"  then CLI::Setup::Territories.call(*)
        when "hooks"        then CLI::Setup::Hooks.call(*)
        else
          parse_options!(command, *, arguments_expected: false)
          help
        end
      end
      #
      # rubocop:enable Metrics/CyclomaticComplexity

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} COMMAND

          A command script to setup the project on your local machine.
          The command '#{bin_prefix('setup')} project' is the default all-in-one setup process.
          It will:

              * install dependencies
              * ask for Rails master key
              * reset development databases
              * reset test databases
              * and few more things

          Available commands are:

              #{bin_prefix('setup')} project           Run the all-in-one setup process
              #{bin_prefix('setup')} dependencies      Check for runtime dependencies (gems & JS)
              #{bin_prefix('setup')} credentials       Check for Rails master key to unlock credentials
              #{bin_prefix('setup')} env               Check for usefull environnment variables
              #{bin_prefix('setup')} databases         Reset development databases
              #{bin_prefix('setup')} test              Reset test databases and build assets
              #{bin_prefix('setup')} submodules        Initialize submodules
              #{bin_prefix('setup')} user              Create a new user through an interactive command
              #{bin_prefix('setup')} territories       Import all EPCIs and communes from a remote source
              #{bin_prefix('setup')} hooks             Setup git hooks to keep project up to date

          Run '#{bin_prefix('setup')} COMMAND --help' for more information on a command.
          \x5
        HEREDOC
      end

      def raise_on_production!
        raise "Are you crazy ?" if ENV["RAILS_ENV"] == "production" || ENV["DOTENV"] == "production"
      end
    end
  end
end
