# frozen_string_literal: true

module Card
  class ComponentPreview < ApplicationViewComponentPreview
    # @label Default
    #
    def default; end

    # @label With header
    #
    def with_header; end

    # @label With actions
    #
    def with_actions; end

    # @label With CSS classes
    #
    def with_css_classes; end
  end
end
