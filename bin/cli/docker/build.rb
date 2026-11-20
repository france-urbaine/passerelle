# frozen_string_literal: true

require_relative "../base"
require_relative "defaults"
require "json"
require "pathname"

module CLI
  module Docker
    class Build < Base
      ROOT_PATH   = Pathname.new(__dir__).join("../../..")
      DOCKER_PATH = ROOT_PATH.join(".docker")

      def call(*)
        parse_options!(*, arguments_expected: false)
        CLI::Docker.ensure_docker_installed

        image_name   = CLI::Docker::IMAGE_NAME
        project_name = CLI::Docker::PROJECT_NAME

        create_docker_folder
        create_bashrc_local
        create_irbrc_local
        create_docker_compose_local_env

        say "Building Docker image #{image_name}"
        run "docker build --file Dockerfile.dev --tag #{image_name} ."

        save_variables(CLI::Docker::ENV_FILE, {
          "IMAGE_NAME"           => image_name,
          "COMPOSE_PROJECT_NAME" => project_name
        })

        say ""
        say "✓ Docker image #{image_name} is ready"
        say ""

        command_options = CLI::Docker.compose_command_options

        say "Build dependent images from docker-compose.dev.yml"
        run "docker compose #{command_options.join(' ')} up --no-start --no-recreate"

        say ""
        say "✓ All dependent images are ready."
        say ""

        print_next_steps
      end

      def help
        say <<~HEREDOC
          Usage:

              bin/dx build

          Builds the images required to start the development environment,
          the one from Dockerfile.dev along with the dependent images
          from docker-compose.dev.yml.

          The build process saves IMAGE_NAME & COMPOSE_PROJECT_NAME to
          #{CLI::Docker::ENV_FILE} so other 'bin/dx' commands use them by default.
          \x5
        HEREDOC
      end

      private

      def create_docker_folder
        DOCKER_PATH.mkpath unless DOCKER_PATH.exist?
      end

      def create_bashrc_local
        path = DOCKER_PATH.join(".bashrc.local")
        return if path.exist?

        say "Creating .docker/.bashrc.local. You can place custom Bash configuration inside"

        path.write <<~BASH
          # Place custom Bash configuration to use inside the running container here.
          # Then rebuild the image with `bin/dx build` to copy the file in your container.
          # Finally, restart your containers with `bin/dx restart`
        BASH
      end

      def create_irbrc_local
        path = DOCKER_PATH.join(".irbrc")
        return if path.exist?

        say "Creating .docker/.irbrc. You can place custom IRB configuration inside"

        path.write <<~RUBY
          # Place custom IRB configuration to use inside the running container here.
          # Then rebuild the image with `bin/dx build` to copy the file in your container.
          # Finally, restart your containers with `bin/dx restart`

          env = ENV.fetch("DOTENV", Rails.env)
          env = case env
                when /dev/  then IRB::Color.colorize(env, [:BLUE])
                when /test/ then IRB::Color.colorize(env, [:BLUE])
                when /prod/ then IRB::Color.colorize(env, [:RED])
                else env
                end

          prompt_prefix = "%N(\#{env})"

          IRB.conf[:PROMPT][:CUSTOM] = {
            PROMPT_I: "\#{prompt_prefix}> ",
            PROMPT_S: "\#{prompt_prefix}%l ",
            PROMPT_C: "\#{prompt_prefix}* ",
            RETURN: "=> %s\\n"
          }

          IRB.conf[:PROMPT_MODE] = :CUSTOM
          IRB.conf[:SAVE_HISTORY] = 100_000
          IRB.conf[:HISTORY_FILE] = ENV["IRB_HISTORY_FILE"]
        RUBY
      end

      def create_docker_compose_local_env
        path = ROOT_PATH.join(CLI::Docker::LOCAL_ENV_FILE)
        return if path.exist?

        say "Creating #{CLI::Docker::LOCAL_ENV_FILE}."
        say "You can set optional per-developer docker-compose variables inside"

        path.write <<~ENV
          # Optional, untracked overrides for docker-compose.dev.yml variable substitution.
          # Generated once by `bin/dx build`: future calls won't overwrite it, so edit freely.
          # Restart your containers with `bin/dx restart` to apply changes.

          # PORT: host port the Rails server is published on (container-side is always 3000,
          # see docker-compose.dev.yml). Override it to avoid a clash with another local
          # service, or to run several projects side by side.
          # PG_PORT, REDIS_PORT and MAILCATCHER_PORT work the same way, for their
          # respective services.
          #
          # PORT=3001
          # PG_PORT=5433
          # REDIS_PORT=6380
          # MAILCATCHER_PORT=1081
        ENV
      end

      def save_variables(relative_path, variables)
        path = ROOT_PATH.join(relative_path)

        say "Saving config variables in #{relative_path}"

        path.open("w") do |file|
          file.puts "# This file is generated via `bin/dx build`. Please do not edit it directly."
          file.puts ""

          variables.each do |key, value|
            file.puts "#{key}=#{value}"
          end
        end
      end

      def print_next_steps
        say "Check for running containers"
        say ""

        if project_running?
          say "Restart & update the running containers with the command:"
          say ""
          say "     bin/dx restart --update"
        else
          say "Is this is your first build ?"
          say "Start & setup the containers with the command:"
          say ""
          say "     bin/dx start --setup"
          say ""
          say "Are you are updating a previous build ?"
          say "Finalize the update with the command:"
          say ""
          say "     bin/dx start --update"
        end

        say ""
      end

      def project_running?
        result = run("docker compose ls --format=json", abort_on_failure: false, capture: true)
        return false unless result

        JSON.parse(result).any? { it["Name"] == CLI::Docker::PROJECT_NAME }
      end
    end
  end
end
