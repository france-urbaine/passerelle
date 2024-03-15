# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class GitHooks < Base
      HOOKS = %w[
        post-merge
        post-checkout
      ].freeze

      def call
        HOOKS.each do |hook|
          template = Pathname.new(__dir__).join("git_hooks", hook).read
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
              next
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

        say "✓ Git hooks set up !"
        say ""
      end
    end
  end
end
