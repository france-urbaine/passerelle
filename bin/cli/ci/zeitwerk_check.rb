# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class ZeitwerkCheck < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Check project structure and class loading through Zeitwerk"
        run "bundle exec rails zeitwerk:check", env: { "RAILS_ENV" => "test" }
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} zeitwerk

          A command script to check project structure and class loading
          using Zeitwerk.
          \x5
        HEREDOC
      end
    end
  end
end
