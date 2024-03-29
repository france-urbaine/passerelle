# frozen_string_literal: true

module Views
  module Reports
    class ShowReportNameComponent < ApplicationViewComponent
      def initialize(report)
        @report = report
        super()
      end

      def call
        key = ".#{i18n_prefix}.#{@report.form_type}."

        t(key, address:, invariant:).html_safe
      end

      def i18n_prefix
        if @report.situation_invariant? && !@report.form_type.start_with?("creation_local_")
          "with_invariant"
        elsif address.present?
          "with_address"
        else
          "blank"
        end
      end

      def invariant
        @report.situation_invariant
      end

      def address
        @report.computed_address
      end
    end
  end
end
