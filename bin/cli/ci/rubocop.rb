# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Rubocop < Base
      def call(*args)
        say "Analyzing code issues with Rubocop"

        command = %w[bundle exec rubocop]

        # explicit rubocop config increases performance slightly while avoiding config confusion.
        command << " --config .rubocop.yml"
        command << " --server --display-cop-names" unless ENV["CI"] == "true"

        command += args

        run command.join(" ")
      end
    end
  end
end
