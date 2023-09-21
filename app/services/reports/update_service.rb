# frozen_string_literal: true

module Reports
  class UpdateService < FormService
    alias_record :report

    before_save do
      if Reports::CheckCompletenessService.new(record).valid?
        record.complete!
      else
        record.incomplete!
      end
    end

    def anomalies=(value)
      report.anomalies = Array.wrap(value)
    end
  end
end
