# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class Territories < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        say "Setup territories"
        say "Loading environment"
        require_relative "../../../config/environment"

        say "Validating URLs:"
        say "  - #{::Passerelle::Application::DEFAULT_COMMUNES_URL}"
        say "  - #{::Passerelle::Application::DEFAULT_EPCIS_URL}"

        service = ::Territories::UpdateService.new(
          communes_url: ::Passerelle::Application::DEFAULT_COMMUNES_URL,
          epcis_url:    ::Passerelle::Application::DEFAULT_EPCIS_URL
        )
        service.validate!

        say ""
        say "URLs are still available."
        say "Import is starting..."
        say "This could take few minutes."
        say ""
        service.perform_now

        say ""
        say "✓ Import completed"
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} territories

          Import all EPCIs and communes from a remote source.
          \x5
        HEREDOC
      end
    end
  end
end
