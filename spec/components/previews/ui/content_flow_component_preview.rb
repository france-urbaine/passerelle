# frozen_string_literal: true

module UI
  # @display frame "content"
  # @display width "medium"
  #
  class ContentFlowComponentPreview < ViewComponent::Preview
    # @label Section with header and actions
    #
    def section_with_header_and_actions; end

    # @label Section with datatable
    #
    def section_with_datatable
      render_with_template(locals: { records: ::Commune.limit(10) })
    end

    # @label Section with separator
    #
    def section_with_separator; end

    # @label Section without header
    #
    def section_without_header; end
  end
end
