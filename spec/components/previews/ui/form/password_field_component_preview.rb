# frozen_string_literal: true

module UI
  module Form
    # @display frame "content"
    # @display width "medium"
    #
    class PasswordFieldComponentPreview < ViewComponent::Preview
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
end
