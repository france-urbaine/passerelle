# frozen_string_literal: true

module Reports
  class CreateService < FormService
    alias_record :report

    attr_accessor :form_type

    def initialize(report, current_user = nil, attributes = {})
      super(report, attributes)

      @current_user = current_user
      @collectivity = current_user.organization if current_user.organization.is_a?(Collectivity)
    end

    before_validation do
      record.anomalies    = []
      record.form_type    = form_type
      record.collectivity = @collectivity
    end
  end
end
