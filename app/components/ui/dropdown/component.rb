# frozen_string_literal: true

module UI
  module Dropdown
    class Component < ApplicationViewComponent
      define_component_helper :dropdown_component

      renders_one :button, lambda { |*args, **options|
        self.button_id = options.delete(:id)

        UI::Button::Component.new(
          *args,
          **options,
          id: button_id,
          aria: { haspopup: "true", expanded: "false" },
          data: { dropdown_target: "button", action: "dropdown#toggle click@window->dropdown#clickOutside" }
        )
      }

      renders_many :items, types: {
        divider: {
          as:       :divider,
          renders:  -> { tag.div(class: "dropdown__divider") }
        },
        menu_item: {
          as:       :menu_item,
          renders:  lambda { |*args, **options|
            item = MenuItem.new(direction: direction)

            if args.any? || options.any?
              options = reverse_merge_attributes(options, {
                role:   "menuitem",
                class:  "dropdown__menu-item"
              })

              icon_options = { icon: "chevron-left-small" }
              icon_options = { icon: "chevron-right-small", icon_position: "right" } if direction == "right"

              item.with_button(*args, **options)
              item.with_dropdown.with_button(*args, **icon_options, **options)
            end

            item
          }
        }
      }

      POSITIONS = %w[below aside].freeze
      DIRECTIONS = %w[right left].freeze

      attr_reader :position, :direction
      attr_writer :button_id

      def initialize(position: "below", direction: "right")
        raise ArgumentError, "invalid position: #{position}" unless POSITIONS.include?(position)
        raise ArgumentError, "invalid direction: #{direction}" unless DIRECTIONS.include?(direction)

        @position = position
        @direction = direction
        super()
      end

      def before_render
        raise "button component is missing" unless button?
      end

      def button_id
        @button_id ||= "dropdown-button-#{SecureRandom.hex(6)}"
      end

      # Use this method to detect component class names with Tailwind
      #
      def position_css_class
        @position_css_class ||=
          case [position, direction]
          when %w[below left]  then "dropdown__menu--below-left"
          when %w[below right] then "dropdown__menu--below-right"
          when %w[aside left]  then "dropdown__menu--aside-left"
          when %w[aside right] then "dropdown__menu--aside-right"
          end
      end

      class MenuItem < ApplicationViewComponent
        renders_one :dropdown, -> { UI::Dropdown::Component.new(position: "aside", direction: direction) }
        renders_one :button, UI::Button::Component

        attr_reader :direction

        def initialize(direction: "right")
          raise ArgumentError, "invalid direction: #{direction}" unless DIRECTIONS.include?(direction)

          @direction = direction
          super()
        end

        def with_menu_item(...)
          dropdown.with_menu_item(...)
        end

        def call
          if dropdown? && dropdown.items.any?
            dropdown
          elsif button?
            button
          else
            tag.div(class: "dropdown__menu-item") do
              content
            end
          end
        end
      end
    end
  end
end
