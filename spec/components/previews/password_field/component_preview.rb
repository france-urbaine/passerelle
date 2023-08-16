# frozen_string_literal: true

module PasswordField
  # @logical_path Interactive elements
  #
  # @display frame "content"
  # @display width "medium"
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With asynchronous strength test
    #
    def with_strength_test; end

    # @label Within a form builder
    #
    def with_formbuilder; end
  end
end
