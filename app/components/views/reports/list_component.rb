# frozen_string_literal: true

module Views
  module Reports
    class ListComponent < ApplicationViewComponent
      include FormatHelper
      include BadgeHelper

      DEFAULT_COLUMNS = %i[
        reference
        form_type
        anomalies
        invariant
        adresse
        commune
        priority
        status
      ].freeze

      def initialize(reports, pagy = nil, parent: nil, searchable: true)
        @reports     = reports
        @pagy        = pagy
        @parent      = parent
        @searchable  = searchable
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        # BadgeHelper.report_badge use package association that's why we need to preload it
        @reports = @reports.preload(:package)      if columns.include?(:package) || columns.include?(:status)
        @reports = @reports.preload(:commune)      if columns.include?(:commune)
        @reports = @reports.preload(:collectivity) if columns.include?(:collectivity)
        @reports = @reports.preload(:workshop)     if columns.include?(:workshop)
      end

      def with_column(name)
        columns << name
      end

      def columns
        @columns ||= []
      end

      def nested?
        @parent
      end
    end
  end
end
