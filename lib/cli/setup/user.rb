# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class User < Base
      def call
        say "Setup user"
        run "bin/rails db:seed", env: { "SEED_INTERACTIVE_USER" => "true" }
      end
    end
  end
end
