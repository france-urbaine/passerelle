# frozen_string_literal: true

require_relative "base"

module CLI
  class Setup < Base
    # I cannot make it simpler
    # rubocop:disable Metrics/CyclomaticComplexity
    #
    def call(arguments: ARGV)
      raise "Are you crazy ?" if ENV["RAILS_ENV"] == "production" || ENV["DOTENV"] == "production"

      case arguments[0]
      when nil           then setup
      when "master_key"  then setup_master_key
      when "env"         then setup_env
      when "dev"         then setup_development
      when "test"        then setup_test(arguments[1])
      when "user"        then setup_user
      when "territories" then setup_territories
      when "mailcatcher" then setup_mailcatcher
      when "submodules"  then setup_submodules
      when "githooks"    then setup_githooks
      else                    help
      end
    end
    #
    # rubocop:enable Metrics/CyclomaticComplexity

    def help
      say <<~MESSAGE
        Setup commands:

            #{program_name}                                     # Run the default setup process
            #{program_name} master_key                          # Add the Rails master key
            #{program_name} env                                 # Define usefull environnment variables
            #{program_name} user                                # Create a new user through an interactive command
            #{program_name} territories                         # Import all EPCIs and communes from a remote source
            #{program_name} mailcatcher                         # Install mailcatcher
            #{program_name} submodules                          # Initialize submodules
            #{program_name} githooks                            # Setup git hooks
            #{program_name} help                                # Show this help

        The default setup process already include the following steps:

            #{program_name} dev                                 # Reset development databases (PG, Redis & ES)
            #{program_name} test                                # Reset test databases and build assets
            #{program_name} test [rspec|parallel|watch|assets]  # Reset only the given subject for testing

        You can also find these other commands useful:

            bin/dev                                       # Start all process to run the app
            bin/ci                                        # Run all tests and checks as CI would
            bin/update                                    # Update some dependencies

        To get more help, try:

            bin/dev help
            bin/ci help
            bin/update help
        \x5
      MESSAGE
    end

    def setup
      setup_dependencies
      setup_development
      setup_test
      setup_submodules

      say "Removing old logs and tempfiles"
      run "bin/rails log:clear tmp:clear"

      say ""
      say <<~MESSAGE
        -------------------------------------------------------------------------------------
        Almost set up, you might find these commands useful to complete your setup:

            bin/setup master_key     # Add the Rails master key (required to use encryption)
            bin/setup env            # Define the most usefull environnment variables
            bin/setup user           # Create a new user through an interactive command
            bin/setup territories    # Import all EPCIs and communes from a remote source
            bin/setup mailcatcher    # Install mailcatcher

        Once you're ready, you can start working with the following commands:

            bin/dev                  # Start all processes to run the app
            bin/ci                   # Run all tests and checks as CI would
            bin/update               # Update some dependencies

        To get more help, try:

            bin/setup help
            bin/dev help
            bin/ci help
            bin/update help

        -------------------------------------------------------------------------------------
      MESSAGE
    end

    def setup_dependencies
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
    end

    def setup_master_key(**)
      require_relative "setup/master_key"

      CLI::Setup::MasterKey.new(program_name).call(**)
    end

    def setup_env
      require_relative "setup/env"

      CLI::Setup::Env.new(program_name).call
    end

    def setup_development
      require_relative "setup/development"

      CLI::Setup::Development.new(program_name).call
    end

    def setup_test(subject = nil)
      require_relative "setup/test"

      CLI::Setup::Test.new(program_name).call(arguments: [subject].compact)
    end

    def setup_user
      require_relative "setup/user"

      CLI::Setup::User.new(program_name).call
    end

    def setup_territories
      require_relative "setup/territories"

      CLI::Setup::Territories.new(program_name).call
    end

    def setup_mailcatcher
      require_relative "setup/mailcatcher"

      CLI::Setup::Mailcatcher.new(program_name).call
    end

    def setup_submodules
      require_relative "setup/git_submodules"

      CLI::Setup::GitSubmodules.new(program_name).call
    end

    def setup_githooks
      require_relative "setup/git_hooks"

      CLI::Setup::GitHooks.new(program_name).call
    end
  end
end
