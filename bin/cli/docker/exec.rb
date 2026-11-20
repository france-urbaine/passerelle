# frozen_string_literal: true

require_relative "command"

module CLI
  class Docker
    class Exec < Command
      def call(*)
        args, options = parse_options!(*, with: options_parser)
        ensure_docker_installed

        command = args.join(" ")
        service = options.fetch(:service, "app")

        exec_options  = ""
        exec_options += options[:env].split(",").map { " --env #{it}" }.join  if options[:env]
        exec_options += " --env DOTENV=#{options[:dotenv]}"                   if options[:dotenv]
        exec_options += " --env RAILS_ENV=#{options[:rails_env]}"             if options[:rails_env]

        say "Execute \"#{command}\" inside container with service named \"#{service}\""
        run "#{compose} exec#{exec_options} #{service} #{command}"
        say "Execution complete"
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx exec [OPTIONS] COMMAND

          This command allows to execute any command inside a container of
          the development environment.

          A service from docker-compose.dev.yml can be provided to execute
          the command. By default, all commands are ran using the 'app' service.

          Options:

              -s, --service   <service>     Name of the service used by the command
              -d, --dotenv    <env>         Value of DOTENV
              -r, --rails_env <env>         Value of RAILS_ENV
              -e, --env       <env>         Set any environment variables (comma separated)

          Example:

              bin/dx exec bash                    Log in to the app service
              bin/dx exec bin/setup               Setup the project in the app service
              bin/dx exec -s redis redis-cli      Run Redis CLI
              bin/dx exec -s postgres psql        Run PSQL from Postgres service
              bin/dx exec -d production rails c   Start a Rails console using .env.production
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("-s SERVICE",  "--service SERVICE")
          parser.on("-d DOTENV",   "--dotenv DOTENV")
          parser.on("-r RAILSENV", "--rails_env RAILSENV")
          parser.on("-e ENV",      "--env ENV")
        end
      end
    end
  end
end
