# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Factories < Base
      def call
        say "Running FactoryBot linter"
        run "bundle exec bin/rails factory_bot:lint", env: { "RAILS_ENV" => "test" }
      end
    end
  end
end
