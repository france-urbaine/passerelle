# frozen_string_literal: true

module UI
  module Tabs
    class Component < ApplicationViewComponent
      define_component_helper :tabs_component

      renders_many :tabs, "Tab"

      def before_render
        tabs.first&.selected = true unless tabs.any?(&:selected)
        tabs.each(&:to_s)
      end

      class Tab < ApplicationViewComponent
        attr_accessor :selected

        def initialize(title, selected: false, sync_all: nil, id: nil)
          @title    = title
          @selected = selected
          @sync_all = sync_all
          parse_html_attributes(id:)
          super()
        end

        def call
          tag.div(
            id:       component_dom_id(:panel),
            class:    "tabs__panel",
            role:     "tabpanel",
            hidden:   !@selected,
            aria:     { labelledby: component_dom_id },
            data:     { tabs_target: "panel" }
          ) do
            content
          end
        end

        def button
          button_component(
            @title,
            id:    component_dom_id,
            class: "tabs__tab #{'tabs__tab--current' if @selected}",
            role:  "tab",
            aria:  {
              controls: component_dom_id(:panel),
              selected: @selected
            },
            data: {
              action:          "click->tabs#select:prevent",
              tabs_target:     "tab",
              tabs_id_param:   component_dom_id,
              tabs_sync_param: @sync_all
            }
          )
        end
      end
    end
  end
end
