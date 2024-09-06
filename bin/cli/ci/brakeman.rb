# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Brakeman < Base
      def call
        say "Analyzing code for security vulnerabilities"
        run "bundle exec brakeman --color -o /dev/stdout -o tmp/brakeman.html"
      end
    end
  end
end
