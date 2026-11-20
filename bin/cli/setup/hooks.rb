# frozen_string_literal: true

require_relative "../base"
require "pathname"
require "open3"
require "tempfile"

module CLI
  module Setup
    class Hooks < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

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

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} hooks

          Setup git hooks (post-merge & post-checkout) to run
          '#{bin_prefix('update')}' and keep the project up to date.
          \x5
        HEREDOC
      end

      def setup_hook(hook, update_command)
        template = format(Pathname.new(__dir__).join("hooks", hook).read, update_command:)
        path     = Pathname.new(".git/hooks").join(hook)

        if path.exist?
          say "The file #{path} already exists. Diff with the version we would install:"
          say ""
          show_diff(path, template)
          say ""

          say "Would you like to override it ? [Yn]"
          return if ask != "Y"
        end

        File.open(path, "w") do |file|
          file.puts template
          file.puts
        end
        path.chmod(0o755)

        say "#{path} created"
        say ""
      end

      # Passed as separate argv entries (not a single interpolated string) so
      # it runs without a shell — no command injection, and it keeps
      # Brakeman happy. `-L` and `--color` are both understood by BSD diff on
      # macOS and GNU diff in the container: `-L` swaps the temp file's
      # throwaway path for a readable label, `--color=always` forces color
      # even though this isn't writing straight to a TTY (say just prefixes
      # each line, it doesn't touch the ANSI codes already inside them).
      #
      def show_diff(path, template)
        Tempfile.create(path.basename.to_s) do |file|
          file.write(template)
          file.close

          diff, = Open3.capture2(
            "diff", "-u", "--color=always",
            "-L", path.to_s, "-L", path.to_s,
            path.to_s, file.path
          )

          diff.empty? ? say("No differences.") : say(diff)
        end
      end
    end
  end
end
