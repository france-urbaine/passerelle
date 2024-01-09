# frozen_string_literal: true

module UI
  module Tabs
    class Component < ApplicationViewComponent
      define_component_helper :tabs_component

      renders_many :tabs, "Tab"

      def before_render
        tabs.each { _1.random_id = random_id }
        tabs.first&.selected = true unless tabs.any?(&:selected)
        tabs.each(&:to_s)
      end

      def random_id
        @random_id ||= SecureRandom.alphanumeric(6)
      end

      class Tab < ApplicationViewComponent
        attr_accessor :selected, :random_id

        def initialize(title, selected: false, sync_all: nil, **options)
          @title    = title
          @selected = selected
          @sync_all = sync_all
          @options  = options
          super()
        end

        def call
          tag.div(
            id:       "#{tab_id}-panel",
            class:    "tabs__panel",
            role:     "tabpanel",
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
              action:          "click->tabs#select:prevent",
              tabs_target:     "tab",
              tabs_id_param:   tab_id,
              tabs_sync_param: @sync_all
            }
          )
        end

        def tab_id
          @tab_id ||= @options.fetch(:id) do
            [random_id, @title.parameterize].join("-")
          end
        end
      end
    end
  end
end
