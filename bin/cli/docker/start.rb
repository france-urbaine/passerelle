# frozen_string_literal: true

require_relative "command"

module CLI
  class Docker
    class Start < Command
      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)
        ensure_docker_installed

        say "Starting development environment"
        run "#{compose} up --detach"

        if options[:setup]
          run "#{compose} exec app bin/setup"
        elsif options[:update]
          run "#{compose} exec app bin/update"
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
