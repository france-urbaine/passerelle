# frozen_string_literal: true

module Pagination
  module Options
    # FIXME: Nested previews are not yet supported
    # https://github.com/ViewComponent/lookbook/pull/311
    #
    class ComponentPreview < ApplicationViewComponentPreview
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
