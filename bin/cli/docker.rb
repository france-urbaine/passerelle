# frozen_string_literal: true

require_relative "base"
require_relative "docker/build"
require_relative "docker/down"
require_relative "docker/exec"
require_relative "docker/restart"
require_relative "docker/start"
require_relative "docker/stop"

module CLI
  class Docker < Base
    def call(*args)
      case args[0]
      when nil, "help" then help
      when "build"     then CLI::Docker::Build.call(*args[1..])
      when "start"     then CLI::Docker::Start.call(*args[1..])
      when "stop"      then CLI::Docker::Stop.call(*args[1..])
      when "restart"   then CLI::Docker::Restart.call(*args[1..])
      when "down"      then CLI::Docker::Down.call(*args[1..])
      when "exec"      then CLI::Docker::Exec.call(*args[1..])
      else
        parse_options!(*args, arguments_expected: false)
        help
      end
    end

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
        \x5
      HEREDOC
    end
  end
end
