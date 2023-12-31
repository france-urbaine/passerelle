# frozen_string_literal: true

module Layout
  module Pagination
    module Buttons
      class Component < ApplicationViewComponent
        define_component_helper :pagination_buttons_component

        attr_reader :pagy, :turbo_frame

        def initialize(pagy, turbo_frame: "_top")
          @pagy        = pagy
          @turbo_frame = turbo_frame
          super()
        end

        def page_url(page)
          new_params = params.slice(:search, :order).permit!
          new_params[:page] = page

          url_for(new_params)
        end

        def previous_button
          UI::Button::Component.new(
            "Page précédente",
            page_url(pagy.prev),
            rel:       "prev",
            icon:      "chevron-left",
            icon_only: true,
            data:      { turbo_frame: }
          )
        end

        def next_button
          UI::Button::Component.new(
            "Page suivante",
            page_url(pagy.next),
            rel:       "next",
            icon:      "chevron-right",
            icon_only: true,
            data: { turbo_frame: }
          )
        end
      end
    end
  end
end
