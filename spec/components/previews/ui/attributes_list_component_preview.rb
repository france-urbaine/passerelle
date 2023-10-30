# frozen_string_literal: true

module UI
  # @display frame "content"
  # @display width "medium"
  #
  class AttributesListComponentPreview < ::Lookbook::Preview
    # @label With attribute name
    #
    def with_attribute_name; end

    # @label With string label
    #
    def with_string_label; end

    # @label With actions
    #
    def with_actions; end
  end
end
