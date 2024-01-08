# frozen_string_literal: true

module Reports
  class UpdateService < FormService
    alias_record :report

    before_save do
      if Reports::CheckCompletenessService.new(record).valid?
        record.ready!
      else
        record.draft!
      end
    end

    def anomalies=(value)
      report.anomalies = Array.wrap(value)
    end
  end
end
