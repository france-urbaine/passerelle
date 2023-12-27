# frozen_string_literal: true

module Views
  module Reports
    class StatusBadgeComponent < ApplicationViewComponent
      define_component_helper :report_badge

      COLORS = {
        incomplete:             "badge--yellow",
        completed:              "badge--lime",
        in_active_transmission: "badge--violet",
        transmitted:            "badge--blue",
        assigned:               "badge--sky",
        returned:               "badge--red",
        approved:               "badge--green",
        rejected:               "badge--red",
        debated:                "badge--orange"
      }.freeze

      def initialize(arg)
        @status =
          case arg
          when Report then report_status(arg)
          when Symbol then arg
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

      def report_status(report)
        if report.returned?
          :returned
        elsif report.rejected?
          :rejected
        elsif report.approved?
          :approved
        elsif report.debated?
          :debated
        elsif report.assigned?
          :assigned
        elsif report.transmitted?
          :transmitted
        elsif report.in_active_transmission?
          :in_active_transmission
        elsif report.completed?
          :completed
        else
          :incomplete
        end
      end
    end
  end
end
