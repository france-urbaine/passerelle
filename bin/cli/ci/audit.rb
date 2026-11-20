# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Audit < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Analyzing ruby gems for security vulnerabilities"
        run "bundle exec bundle audit check --update"
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} audit

          Checks the Gemfile.lock for insecure dependencies
          \x5
        HEREDOC
      end
    end
  end
end
