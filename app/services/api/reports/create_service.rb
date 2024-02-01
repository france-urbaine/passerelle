# frozen_string_literal: true

module API
  module Reports
    class CreateService < FormService
      alias_record :report

      validate do
        promote_errors(completeness_service.errors) if completeness_service.invalid?
      end

      before_save do
        report.complete if errors.empty?
      end

      def anomalies=(value)
        report.anomalies = Array.wrap(value)
      end

      def completeness_service
        @completeness_service ||= ::Reports::CheckCompletenessService.new(report)
      end
    end
  end
end
