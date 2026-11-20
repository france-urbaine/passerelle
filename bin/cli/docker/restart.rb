# frozen_string_literal: true

require_relative "../base"
require_relative "defaults"

module CLI
  module Docker
    class Restart < Base
      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)
        CLI::Docker.ensure_docker_installed

        command_options = CLI::Docker.compose_command_options

        say "Stopping development environment"
        run "docker compose #{command_options.join(' ')} stop"

        say "Starting development environment"
        run "docker compose #{command_options.join(' ')} up --detach"

        run "docker compose #{command_options.join(' ')} exec app bin/update" if options[:update]

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
