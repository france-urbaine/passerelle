# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class Submodules < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Update vendorized submodules"
        run "git submodule init"
        run "git submodule update"

        say ""
        say "✓ Submodules are ready !"
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} submodules

          Initialize and update vendorized git submodules.
          \x5
        HEREDOC
      end
    end
  end
end
