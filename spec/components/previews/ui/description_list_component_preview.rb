# frozen_string_literal: true

module UI
  # @display frame "content"
  # @display width "medium"
  #
  class DescriptionListComponentPreview < ::Lookbook::Preview
    # @label With attribute name only
    #
    def with_attribute_name_only; end

    # @label With attribute name and content
    #
    def with_attribute_name_and_content; end

    # @label With string label
    #
    def with_string_label; end

    # @label With actions
    #
    def with_actions; end

    # @label With reference
    #
    def with_reference; end

    # @label With blank value
    #
    def with_blank_value; end
  end
end
