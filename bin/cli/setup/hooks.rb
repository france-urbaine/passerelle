# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class Hooks < Base
      def call
        # Hooks are triggered by git on the host: when they are set up from
        # inside the container (ENV["DOCKER"] is set by docker-compose.dev.yml),
        # they need `bin/dx` to reach the container.
        #
        update_command = ENV["DOCKER"] ? "bin/dx update" : "bin/update"

        setup_hook "post-merge", update_command
        setup_hook "post-checkout", update_command

        say "✓ Git hooks set up !"
        say ""
      end

      def setup_hook(hook, update_command)
        template = format(Pathname.new(__dir__).join("hooks", hook).read, update_command:)
        path     = Pathname.new(".git/hooks").join(hook)

        if path.exist?
          say "The file #{path} already exists:"
          run "cat #{path}"

          say "Would you like to override it ? [Yn]"

          if ask != "Y"
            say "Skipped, you may have to add the following lines to the file:"
            $stdout.puts
            $stdout.puts template
            $stdout.puts
            return
          end

          run "rm #{path}"
        end

        run "touch #{path}"
        run "chmod +x #{path}"

        File.open(path, "w") do |file|
          file.puts template
          file.puts
        end

        say "#{path} created"
        say ""
      end
    end
  end
end
