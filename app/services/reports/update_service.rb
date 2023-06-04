# frozen_string_literal: true

module Reports
  class UpdateService < FormService
    attr_reader :report
    delegate_missing_to :report

    def initialize(report, attributes = {})
      @report = report

      super(attributes)
      self.models = [report]
    end

    before_save do
      self.completed = Reports::CheckCompletenessService.new(report).valid?
    end
  end
end