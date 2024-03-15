# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Mailcatcher < Base
      def call
        say "Install mailcatcher"

        return if run("gem install mailcatcher --pre", abort_on_failure: false)

        say "Failed to install mailcatcher"

        if command_available?("brew")
          say "Homebrew detected"
          say "Retry with option: --with-openssl-dir=$(brew --prefix openssl@1.1)"

          return if run(
            "gem install mailcatcher --pre -- --with-openssl-dir=$(brew --prefix openssl@1.1)",
            abort_on_failure: false
          )

          say "Failed to install mailcatcher"
          abort
        end

        say "Read more about potential issues:"
        say " . https://github.com/eventmachine/eventmachine/issues/936"
        say " . https://github.com/sj26/mailcatcher#rvm"
        say " . https://github.com/sj26/mailcatcher#ruby"
      end
    end
  end
end
