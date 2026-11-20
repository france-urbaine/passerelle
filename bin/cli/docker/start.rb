# frozen_string_literal: true

require_relative "../base"
require_relative "defaults"

module CLI
  module Docker
    class Start < Base
      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)
        CLI::Docker.ensure_docker_installed

        command_options = CLI::Docker.compose_command_options

        say "Starting development environment"
        run "docker compose #{command_options.join(' ')} up --detach"

        if options[:setup]
          run "docker compose #{command_options.join(' ')} exec app bin/setup project"
        elsif options[:update]
          run "docker compose #{command_options.join(' ')} exec app bin/update"
        end

        say "Development environment started"
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx start [OPTIONS]

          Creates & starts all containers from the development environment.

          Options:

              --setup             Execute the default setup command on start
              --update            Update the container on start
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--setup")
          parser.on("--update")
        end
      end
    end
  end
end
