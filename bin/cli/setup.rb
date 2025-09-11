# frozen_string_literal: true

require_relative "base"

module CLI
  class Setup < Base
    # rubocop:disable Metrics/CyclomaticComplexity
    #
    # Rubocop found it complex because of one long case/when statement,
    # but, that's just a case statement!
    #
    def call(*args)
      raise "Are you crazy ?" if ENV["RAILS_ENV"] == "production" || ENV["DOTENV"] == "production"

      case args[0]
      when nil           then setup
      when "env"         then CLI::Setup::Env.call
      when "hooks"       then CLI::Setup::Hooks.call
      when "mailcatcher" then CLI::Setup::Mailcatcher.call
      when "master_key"  then CLI::Setup::MasterKey.call
      when "reset"       then CLI::Setup::Reset.call
      when "submodules"  then CLI::Setup::Submodules.call
      when "territories" then CLI::Setup::Territories.call
      when "test"        then CLI::Setup::Test.call(*args[1..])
      when "user"        then CLI::Setup::User.call
      else help
      end
    end
    #
    # rubocop:enable Metrics/CyclomaticComplexity

    def help
      say <<~MESSAGE
        Setup commands:

            bin/setup                                     # Run the default setup process
            bin/setup user                                # Create a new user through an interactive command
            bin/setup territories                         # Import all EPCIs and communes from a remote source
            bin/setup mailcatcher                         # Install mailcatcher
            bin/setup hooks                               # Setup git hooks to keep project up to date
            bin/setup help                                # Show this help

        The default setup process already include the following steps:

            bin/setup master_key                          # Add the Rails master key
            bin/setup env                                 # Define usefull environnment variables
            bin/setup reset                               # Reset development databases (PG, Redis & ES)
            bin/setup test                                # Reset test databases and build assets
            bin/setup test [rspec|parallel|watch|assets]  # Reset only the given subject for testing
            bin/setup submodules                          # Initialize submodules

        You can also find these other commands useful:

            bin/dev                                       # Start all process to run the app
            bin/ci                                        # Run all tests and checks as CI would
            bin/update                                    # Keep the project updated
            bin/upgrade                                   # Upgrade dependencies
        \x5
      MESSAGE
    end

    def setup
      # Install bundler if it's missing but don't attempt
      # to upgrade already existing version
      #
      # Only do bundle install if the much-faster bundle check
      # indicates we need to
      #
      say "Installing gems"
      run "gem install bundler --conservative"
      run "bundle check || bundle install"

      say "Installing JS packages"
      run "yarn"

      say ""
      say "✓ All dependencies are satisfied."
      say ""

      run "bin/setup master_key", env: { "IGNORE_EXISTING_KEY" => "true" }
      run "bin/setup env"
      run "bin/setup reset"
      run "bin/setup test"
      run "bin/setup submodules"

      say "Removing old logs and tempfiles"
      run "bin/rails log:clear tmp:clear"
      say ""
      say <<~MESSAGE
        -------------------------------------------------------------------------------------

        Everything is set up!
        You might find these commands useful to complete your setup:

            bin/setup user            # Create a new user through an interactive command
            bin/setup territories     # Import all EPCIs and communes from a remote source
            bin/setup mailcatcher     # Install mailcatcher
            bin/setup hooks           # Setup git hooks to keep project up to date

        Once you're ready, you can start working with the following commands:

            bin/dev                   # Start all processes to run the app
            bin/ci                    # Run all tests and checks as CI would
            bin/update                # Keep the project up to date
            bin/upgrade               # Upgrade dependencies

        -------------------------------------------------------------------------------------
      MESSAGE
    end
  end
end
