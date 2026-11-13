# frozen_string_literal: true

require_relative "command"

module CLI
  class Docker
    class Stop < Command
      def call(*)
        parse_options!(*, arguments_expected: false)
        ensure_docker_installed

        say "Stopping development environment"
        run "#{compose} stop"

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
