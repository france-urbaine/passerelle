# frozen_string_literal: true

module Reports
  class UpdateService < FormService
    alias_record :report

    before_save do
      if completeness_service.valid?
        report.complete
      else
        report.resume
      end
    end

    def anomalies=(value)
      report.anomalies = Array.wrap(value)
    end

    def completeness_service
      @completeness_service ||= Reports::CheckCompletenessService.new(report)
    end
  end
end
