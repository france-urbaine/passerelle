# frozen_string_literal: true

module RadioButtons
  # @logical_path Interactive elements
  # @display frame "content"
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label Resettable
    #
    def resettable; end

    # @label With a form builder
    #
    def with_formbuilder; end
  end
end
