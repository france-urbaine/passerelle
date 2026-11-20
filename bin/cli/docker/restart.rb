# frozen_string_literal: true

require_relative "command"

module CLI
  class Docker
    class Restart < Command
      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)
        ensure_docker_installed

        say "Stopping development environment"
        run "#{compose} stop"

        say "Starting development environment"
        run "#{compose} up --detach"

        run "#{compose} exec app bin/update" if options[:update]

        say "Development environment started"
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx restart [OPTIONS]

          Stops running containers from the development environment,
          then recreates & restarts them.

          Options:

              --update            Update the container after restart
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--update")
        end
      end
    end
  end
end
