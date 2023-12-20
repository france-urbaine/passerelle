# frozen_string_literal: true

module Views
  module Packages
    class StatusBadgeComponent < ApplicationViewComponent
      define_component_helper :package_badge

      COLORS = {
        transmitted: "badge--blue",
        assigned:    "badge--green",
        denied:      "badge--red"
      }.freeze

      def initialize(arg)
        @status =
          case arg
          when Package then package_status(arg)
          when Symbol  then arg
          else raise TypeError, "invalid argument: #{arg.inspect}"
          end

        super()
      end

      def call
        badge_component(label, class: css_class)
      end

      def label
        t(".#{@status}")
      end

      def css_class
        COLORS[@status]
      end

      def package_status(package)
        if package.reports&.all?(&:denied?)
          :denied
        elsif package.reports&.all?(&:assigned?)
          :assigned
        else
          :transmitted
        end
      end
    end
  end
end
