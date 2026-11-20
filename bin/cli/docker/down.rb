# frozen_string_literal: true

require_relative "../base"
require_relative "defaults"

module CLI
  module Docker
    class Down < Base
      def call(*)
        parse_options!(*, arguments_expected: false)
        CLI::Docker.ensure_docker_installed

        command_options = CLI::Docker.compose_command_options

        say "Stopping development environment"
        run "docker compose #{command_options.join(' ')} down"

        say "Development environment down"
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx down

          Stops & removes containers and networks used for
          the development environment.

          Data volumes (Postgres, Redis, ...) are kept.
          \x5
        HEREDOC
      end
    end
  end
end
