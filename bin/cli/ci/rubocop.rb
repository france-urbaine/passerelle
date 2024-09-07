# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Rubocop < Base
      def call(*args)
        say "Analyzing code issues with Rubocop"

        command = "bundle exec rubocop"
        command += " --server --display-cop-names" unless ENV["CI"] == "true"
        command += " #{args.join(' ')}" if args.any?

        run command
      end
    end
  end
end
