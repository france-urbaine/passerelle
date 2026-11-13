# frozen_string_literal: true

require_relative "command"
require "json"
require "pathname"

module CLI
  class Docker
    class Build < Command
      ROOT_PATH   = Pathname.new(__dir__).join("../../..")
      DOCKER_PATH = ROOT_PATH.join(".docker")

      def call(*)
        parse_options!(*, arguments_expected: false)
        ensure_docker_installed

        create_docker_folder
        create_bashrc_local
        create_irbrc_local

        say "Building Docker image #{IMAGE_NAME}"
        run "docker build --file Dockerfile.dev --tag #{IMAGE_NAME} ."

        save_variables(ENV_FILE, {
          "IMAGE_NAME"           => IMAGE_NAME,
          "COMPOSE_PROJECT_NAME" => PROJECT_NAME
        })

        say ""
        say "✓ Docker image #{IMAGE_NAME} is ready"
        say ""

        say "Build dependent images from docker-compose.dev.yml"
        run "#{compose} up --no-start --no-recreate"

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
          #{ENV_FILE} so other 'bin/dx' commands use them by default.
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
        result = `docker compose ls --format=json`
        return false unless run_succeed?

        JSON.parse(result).any? { it["Name"] == PROJECT_NAME }
      end
    end
  end
end
