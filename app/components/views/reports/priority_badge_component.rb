# frozen_string_literal: true

module Views
  module Reports
    class PriorityBadgeComponent < ApplicationViewComponent
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
        text += priority_icon_component(@priority)

        badge_component(text.html_safe, class: ["priority-badge", COLORS[@priority]])
      end
    end
  end
end
