# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Rubocop < Base
      def call(*args)
        parse_options!(*args, raise_unknown: false)

        say "Analyzing code issues with Rubocop"

        command = %w[bundle exec rubocop]

        # explicit rubocop config increases performance slightly while avoiding config confusion.
        command << " --config .rubocop.yml"
        command << " --server --display-cop-names" unless ENV["CI"] == "true"

        command += args

        run command.join(" ")
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} rubocop [OPTIONS] [FILE, ...]

          A command script to call Rubocop.
          It accepts all options and argument used by rubocop:
          \x5
        HEREDOC

        run "bundle exec rubocop --help"
      end
    end
  end
end
