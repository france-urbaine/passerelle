# frozen_string_literal: true

module Views
  module Reports
    module List
      class Component < ApplicationViewComponent
        include FormatHelper

        DEFAULT_COLUMNS = %i[
          state
          form_type
          invariant
          adresse
          commune
          anomalies
          priority
          reference
        ].freeze

        DATE_COLUMNS = %i[
          transmitted_at
          accepted_at
          assigned_at
          resolved_at
          returned_at
        ].freeze

        def initialize(reports, pagy = nil, parent: nil, dashboard: false)
          @reports     = reports
          @pagy        = pagy
          @parent      = parent
          @dashboard   = dashboard
          super()
        end

        def before_render
          content

          # Always eager load package, it's may be used for policy check
          @reports = @reports.preload(:package, :transmission, :office, :ddfip)

          @reports = @reports.preload(:commune)      if columns.include?(:commune)
          @reports = @reports.preload(:collectivity) if columns.include?(:collectivity)
          @reports = @reports.preload(:ddfip)        if columns.include?(:ddfip)
        end

        def with_column(name)
          columns << name
        end

        def remove_column(name)
          columns.delete(name)
        end

        def columns
          @columns ||= DEFAULT_COLUMNS.dup
        end

        def nested?
          @parent
        end

        def report_sender?
          %w[Collectivity Publisher].include?(current_user.organization_type)
        end

        def date_columns
          dates =
            if columns.include?(:transition_dates)
              DATE_COLUMNS.dup
            else
              DATE_COLUMNS & columns
            end

          dates &= %i[transmitted_at resolved_at] if report_sender?
          dates
        end

        def date_label(column)
          if report_sender?
            t(".collectivity.#{column}")
          elsif columns.include?(:transition_dates)
            t(".ddfip.compact.#{column}")
          else
            t(".ddfip.full.#{column}")
          end
        end
      end
    end
  end
end
