# frozen_string_literal: true

require_relative "../base"
require_relative "defaults"

module CLI
  module Docker
    class Stop < Base
      def call(*)
        parse_options!(*, arguments_expected: false)
        CLI::Docker.ensure_docker_installed

        command_options = CLI::Docker.compose_command_options

        say "Stopping development environment"
        run "docker compose #{command_options.join(' ')} stop"

        say "Development environment stopped"
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx stop

          Stops running containers from the development environment.
          \x5
        HEREDOC
      end
    end
  end
end
