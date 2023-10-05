# frozen_string_literal: true

module API
  module Reports
    class UpdateService < FormService
      alias_record :report

      before_save do
        completeness_service = ::Reports::CheckCompletenessService.new(record)
        unless completeness_service.valid?
          merge_completeness_errors(completeness_service.errors)
          throw(:abort)
        end
      end

      def anomalies=(value)
        report.anomalies = Array.wrap(value)
      end

      private

      def merge_completeness_errors(completeness_errors)
        completeness_errors.each do |error|
          record.errors.add(error.attribute, error.message)
        end
      end
    end
  end
end
