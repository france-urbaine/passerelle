# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class GitSubmodules < Base
      def call
        say "Update vendorized submodules"
        run "git submodule init"
        run "git submodule update"

        say ""
        say "✓ Submodules updated !"
        say ""
      end
    end
  end
end
