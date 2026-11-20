# frozen_string_literal: true

require_relative "base"
require_relative "docker/defaults"
require_relative "docker/build"
require_relative "docker/down"
require_relative "docker/exec"
require_relative "docker/restart"
require_relative "docker/start"
require_relative "docker/stop"

module CLI
  module Docker
    def self.run = Default.run

    class Default < Base
      # rubocop:disable Metrics/CyclomaticComplexity
      # Rubocop found it complex because of one long case/when statement.
      #
      def call(command = nil, *)
        case command
        when "build"    then CLI::Docker::Build.call(*)
        when "start"    then CLI::Docker::Start.call(*)
        when "stop"     then CLI::Docker::Stop.call(*)
        when "restart"  then CLI::Docker::Restart.call(*)
        when "down"     then CLI::Docker::Down.call(*)
        when "exec"     then CLI::Docker::Exec.call(*)
        when "sh"       then CLI::Docker::Exec.call("bash")
        when "rails"    then CLI::Docker::Exec.call("bin/rails", *)
        when "setup"    then CLI::Docker::Exec.call("bin/setup", *)
        when "ci"       then CLI::Docker::Exec.call("bin/ci", *)
        when "rspec"    then CLI::Docker::Exec.call("bundle exec rspec", *)
        when "update"   then CLI::Docker::Exec.call("bin/update", *)
        when "upgrade"  then CLI::Docker::Exec.call("bin/upgrade", *)
        when "dev"      then CLI::Docker::Exec.call("bin/dev", *)
        when "server"   then CLI::Docker::Exec.call("bin/dev server", *)
        when "jobs"     then CLI::Docker::Exec.call("bin/dev jobs", *)
        when "psql"     then CLI::Docker::Exec.call("-s", "postgres", "psql -U postgres -d passerelle_development")
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

              bin/dx COMMAND

          A command script to manage the development environment via Docker images
          and containers.

          Available commands are:

              bin/dx build              Builds the Docker image from Dockerfile.dev
              bin/dx start              Creates & starts all containers
              bin/dx stop               Stops all containers
              bin/dx restart            Stops, recreates & restarts all containers
              bin/dx down               Stops & removes all containers and networks
              bin/dx exec               Executes a command inside a container

          Run 'bin/dx COMMAND --help' for more information on a command.
          It also includes few shortcuts for the 'exec' command:

              bin/dx sh                 → bin/dx exec bash
              bin/dx rails [args]       → bin/dx exec bin/rails [args]
              bin/dx setup [args]       → bin/dx exec bin/setup [args]
              bin/dx ci [args]          → bin/dx exec bin/ci [args]
              bin/dx rspec [file]       → bin/dx exec bundle exec rspec [file]
              bin/dx update [args]      → bin/dx exec bin/update [args]
              bin/dx upgrade [args]     → bin/dx exec bin/upgrade [args]
              bin/dx dev [args]         → bin/dx exec bin/dev [args]
              bin/dx server [args]      → bin/dx exec bin/dev server [args]
              bin/dx jobs [args]        → bin/dx exec bin/dev jobs [args]
              bin/dx psql               → bin/dx exec -s postgres psql -U postgres -d passerelle_development
          \x5
        HEREDOC
      end
    end
  end
end
