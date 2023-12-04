# frozen_string_literal: true

module Layout
  module Pagination
    # @display frame "content"
    #
    class OptionsComponentPreview < ViewComponent::Preview
      # @!group Options
      #
      # @label Default
      #
      def default
        render_with_template(locals: { pagy: })
      end

      # @label With actions targeting a turbo-frame
      #
      def with_turbo_frame
        render_with_template(locals: { pagy: })
      end

      # @label With directions
      #
      def with_direction
        render_with_template(locals: { pagy: })
      end

      # @label With order options
      #
      def with_orders
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
