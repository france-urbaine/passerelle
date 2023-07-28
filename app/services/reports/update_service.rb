# frozen_string_literal: true

module Reports
  class UpdateService < FormService
    alias_record :report

    before_save do
      record.completed = Reports::CheckCompletenessService.new(record).valid?
    end
  end
end
