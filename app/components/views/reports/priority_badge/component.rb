# frozen_string_literal: true

module Views
  module Reports
    module PriorityBadge
      class Component < ApplicationViewComponent
        define_component_helper :priority_badge

        COLORS = {
          low:    "badge--lime",
          medium: "badge--yellow",
          high:   "badge--orange"
        }.freeze

        def initialize(arg)
          @priority =
            case arg
            when Report then arg.priority.to_sym
            when Symbol then arg
            else raise TypeError, "invalid argument: #{arg.inspect}"
            end

          super()
        end

        def call
          text  = "Priorité : "
          text += render PriorityIcon::Component.new(@priority)

          css_class = "priority-badge "
          css_class += COLORS[@priority]

          badge_component(text.html_safe, class: css_class) # rubocop:disable Rails/OutputSafety
        end
      end
    end
  end
end
