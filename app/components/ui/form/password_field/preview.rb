# frozen_string_literal: true

module UI
  module Form
    module PasswordField
      # @display frame "content"
      # @display width "medium"
      #
      class Preview < ApplicationViewComponentPreview
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
end
