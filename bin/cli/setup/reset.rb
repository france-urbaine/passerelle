# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Reset < Base
      def call
        say "Dropping & recreating the development & test databases"
        run "bin/rails db:reset", env: { "SETUP_SEED" => "true" }

        say ""
        say "✓ Development database is ready."
        say ""
      end
    end
  end
end
