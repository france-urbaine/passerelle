# frozen_string_literal: true

require_relative "base"

module CLI
  class Docker < Base
    def call(*args)
      case args[0]
      when nil, "help" then help
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

        Run 'bin/dx COMMAND --help' for more information on a command.
        \x5
      HEREDOC
    end
  end
end
