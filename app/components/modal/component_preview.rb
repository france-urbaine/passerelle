# frozen_string_literal: true

module Modal
  # @display frame "modal"
  #
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

    # @label Redirection after closing (noJS)
    #
    def with_redirection; end

    # @label With a form
    #
    def with_form
      record = ::Commune.new
      render_with_template(locals: { record: record })
    end
  end
end
