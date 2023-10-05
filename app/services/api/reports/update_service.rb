# frozen_string_literal: true

module API
  module Reports
    class UpdateService < FormService
      alias_record :report

      before_save do
        completeness_service = ::Reports::CheckCompletenessService.new(record)
        unless completeness_service.valid?
          promote_errors(record)
          throw(:abort)
        end
      end

      def anomalies=(value)
        report.anomalies = Array.wrap(value)
      end
    end
  end
end
