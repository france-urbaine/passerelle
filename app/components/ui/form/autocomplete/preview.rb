# frozen_string_literal: true

module UI
  module Form
    module Autocomplete
      # @display frame "content"
      # @display width "medium"
      #
      class Preview < ApplicationViewComponentPreview
        # @label Default
        #
        def default; end

        # @label With options
        #
        def with_options; end

        # @label With current object
        #
        def with_current_object; end

        # @label With custom fields
        #
        def with_custom_fields; end

        # @label With a form builder
        #
        def with_formbuilder; end

        # @label Without JS
        #
        def with_noscript; end
      end
    end
  end
end
