# frozen_string_literal: true

module UI
  class TabsComponent < ApplicationViewComponent
    define_component_helper :tabs_component

    renders_many :tabs, "Tab"

    def before_render
      tabs.first&.selected = true unless tabs.any?(&:selected)
      tabs.each(&:to_s)
    end

    class Tab < ApplicationViewComponent
      attr_accessor :selected

      def initialize(title, selected: false, **options)
        @title    = title
        @selected = selected
        @options  = options
        super()
      end

      def call
        tag.div(
          id:       "#{tab_id}-panel",
          class:    "tabs__panel",
          role:     "tabpanel",
          tabindex: 0,
          hidden:   !@selected,
          aria:     { labelledby: tab_id },
          data:     { tabs_target: "panel" }
        ) do
          content
        end
      end

      def button
        button_component(
          @title,
          id:    tab_id,
          class: "tabs__tab #{'tabs__tab--current' if @selected}",
          role:  "tab",
          aria: {
            controls: "#{tab_id}-panel",
            selected: @selected
          },
          data: {
            action:        "click->tabs#select:prevent",
            tabs_target:   "tab",
            tabs_id_param: tab_id
          }
        )
      end

      def tab_id
        @tab_id ||= @options.fetch(:id) { @title.parameterize }
      end
    end
  end
end
