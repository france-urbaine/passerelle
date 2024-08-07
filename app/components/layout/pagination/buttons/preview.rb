# frozen_string_literal: true

module Layout
  module Pagination
    module Buttons
      # @display frame "content"
      #
      class Preview < ApplicationViewComponentPreview
        # @!group Buttons
        #
        # @label Default
        #
        def default
          render_with_template(locals: { pagy: })
        end

        # @label Buttons targeting a turbo-frame
        #
        def with_turbo_frame
          render_with_template(locals: { pagy: })
        end
        #
        # @!endgroup

        private

        def pagy
          Pagy.new(count: 125, page: 3, limit: 20)
        end
      end
    end
  end
end
