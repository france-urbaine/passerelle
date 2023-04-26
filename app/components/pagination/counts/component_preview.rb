# frozen_string_literal: true

module Pagination
  module Counts
    # FIXME: Nested previews are not yet supported
    # https://github.com/ViewComponent/lookbook/pull/311
    #
    class ComponentPreview < ApplicationViewComponentPreview
      # @!group Counts
      #
      # @label Default
      #
      def default
        render_with_template(locals: { pagy: })
      end

      # @label With countable model
      #
      def with_countable_model
        render_with_template(locals: { pagy: })
      end

      # @label With countable word
      #
      def with_countable_word
        render_with_template(locals: { pagy: })
      end

      # @label With irregular inflections
      #
      def with_inflections
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
