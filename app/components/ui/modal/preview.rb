# frozen_string_literal: true

module UI
  module Modal
    # @display frame "modal"
    #
    class Preview < ApplicationViewComponentPreview
      DEFAULT_REFERRER = "/rails/view_components/samples/turbo/content"

      # @label Default
      #
      def default; end

      # @label With header
      #
      def with_header; end

      # @label With actions
      #
      def with_actions; end

      # @label With referrer
      # @param referrer text "Referrer URL"
      #
      # `referrer` option allows you to perform a redirection when the modal is closed and Javascript is disabled.
      #
      def with_referrer(referrer: DEFAULT_REFERRER)
        render_with_template(locals: { referrer: })
      end

      # @label With a form
      #
      def with_form
        record = ::Commune.new
        render_with_template(locals: { record: record })
      end
    end
  end
end
