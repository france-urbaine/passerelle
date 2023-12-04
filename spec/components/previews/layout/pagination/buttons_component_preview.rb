# frozen_string_literal: true

module Layout
  module Pagination
    # @display frame "content"
    #
    class ButtonsComponentPreview < ViewComponent::Preview
      # @!group Buttons
      #
      # @label Default
      #
      def default
        render_with_template(locals: { pagy: })
      end

      # @label Buttons targeting a turbo-frame
      #
      def with_turbo_frame
        render_with_template(locals: { pagy: })
      end
      #
      # @!endgroup

      private

      def pagy
        Pagy.new(count: 125, page: 3, items: 20)
      end
    end
  end
end
