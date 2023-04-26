# frozen_string_literal: true

module Pagination
  class ComponentPreview < ApplicationViewComponentPreview
    # @!group Default
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

    # @label Buttons targeting a turbo-frame
    #
    def with_turbo_frame
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
