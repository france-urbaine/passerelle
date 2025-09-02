# frozen_string_literal: true

module UI
  module Timeline
    class Component
      class Step < ApplicationViewComponent
        CSS_CLASSES = {
          pending:  "timeline-step--pending",
          current:  "timeline-step--current",
          done:     "timeline-step--done",
          failed:   "timeline-step--failed"
        }.freeze

        attr_reader :title, :description, :status, :date, :icon

        delegate :date_format, to: :@timeline

        def initialize(timeline, title, status: :pending, date: nil, icon: nil, **)
          status = status.to_sym if status.is_a?(String)
          raise ArgumentError, "unexpected status: #{status.inspect}" unless CSS_CLASSES.include?(status)

          @timeline        = timeline
          @title           = title
          @status          = status
          @date            = date
          @icon            = icon
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def html_attributes
          reverse_merge_attributes(@html_attributes, {
            class: CSS_CLASSES.fetch(@status)
          })
        end
      end
    end
  end
end
