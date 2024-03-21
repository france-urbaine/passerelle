# frozen_string_literal: true

require_relative "../base"
require_relative "../../../config/environment"

module CLI
  class Setup
    class Territories < Base
      def call
        say "Import all territories"
        say "This could take a while."

        ::Territories::UpdateService.new(
          communes_url: ::Passerelle::Application::DEFAULT_COMMUNES_URL,
          epcis_url:    ::Passerelle::Application::DEFAULT_EPCIS_URL
        ).perform_now
      end
    end
  end
end
