# frozen_string_literal: true

module Views
  module Reports
    class StatusBadgeComponent < ApplicationViewComponent
      define_component_helper :report_badge

      COLORS = {
        draft:                  "badge--yellow",
        ready:                  "badge--lime",
        in_active_transmission: "badge--violet",
        transmitted:            "badge--blue",
        processing:             "badge--sky",
        denied:                 "badge--red",
        approved:               "badge--green",
        rejected:               "badge--red"
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
        if report.denied?
          :denied
        elsif report.rejected?
          :rejected
        elsif report.approved?
          :approved
        elsif report.processing?
          :processing
        elsif report.transmitted?
          :transmitted
        elsif report.in_active_transmission?
          :in_active_transmission
        elsif report.ready?
          :ready
        else
          :draft
        end
      end
    end
  end
end
