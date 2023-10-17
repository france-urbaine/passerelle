# frozen_string_literal: true

module UI
  module Form
    # @display frame "content"
    #
    class HiddenFieldComponentPreview < ViewComponent::Preview
      # @label Default
      #
      def default; end

      # @label With an Array value
      #
      def with_array_value; end

      # @label With a Hash value
      #
      def with_hash_value; end
    end
  end
end
