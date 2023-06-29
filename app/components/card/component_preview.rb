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

    # @label With a form
    #
    def with_form
      record = ::Commune.new
      render_with_template(locals: { record: record })
    end

    # @label With multipart
    #
    def with_multipart
      record = ::Commune.new
      render_with_template(locals: { record: record })
    end
  end
end
