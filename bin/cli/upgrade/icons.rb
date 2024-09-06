# frozen_string_literal: true

require_relative "../base"

module CLI
  class Upgrade
    class Icons < Base
      def call
        say "Updating Heroicons set"
        run "git submodule update --remote vendor/submodules/heroicons"
      end
    end
  end
end
