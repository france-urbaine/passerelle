# frozen_string_literal: true

module API
  module Reports
    class CreateService < FormService
      alias_record :report

      validate do
        promote_errors(completeness_service) if completeness_service.invalid?
      end

      after_validation do
        if errors.any?
          report.errors.merge!(completeness_service.errors)
        else
          report.completed_at = Time.zone.now
        end
      end

      def anomalies=(value)
        report.anomalies = Array.wrap(value)
      end

      private

      def completeness_service
        @completeness_service ||= ::Reports::CheckCompletenessService.new(report)
      end
    end
  end
end
