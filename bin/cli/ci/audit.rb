# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Audit < Base
      def call
        say "Analyzing ruby gems for security vulnerabilities"
        run "bundle exec bundle audit check --update"
      end
    end
  end
end
