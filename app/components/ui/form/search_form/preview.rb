# frozen_string_literal: true

module UI
  module Form
    module SearchForm
      # @display frame "content"
      # @display width "small"
      #
      class Preview < ApplicationViewComponentPreview
        # @label Default
        #
        def default; end

        # @label With a custom label
        #
        def with_label; end

        # @label With another URL
        #
        def with_url; end

        # @label With form targeting a turbo-frame
        #
        def with_turbo_frame; end
      end
    end
  end
end
