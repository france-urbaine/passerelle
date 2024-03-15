# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Territories < Base
      def call
        say "Import all territories"
        say "This could take a while."

        run "bin/rails db:seed", env: { "SEED_ALL_EPCIS_AND_COMMUNES" => "true" }
      end
    end
  end
end
