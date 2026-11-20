# frozen_string_literal: true

require_relative "command"

module CLI
  class Docker
    class Down < Command
      def call(*)
        parse_options!(*, arguments_expected: false)
        ensure_docker_installed

        say "Stopping development environment"
        run "#{compose} down"

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
