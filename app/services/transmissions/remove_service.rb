# frozen_string_literal: true

module Transmissions
  class RemoveService
    attr_reader :removed_reports_count, :after_transmission_reports_count

    def initialize(transmission)
      @transmission                      = transmission
      @removed_report_ids                = []
      @before_transmission_reports_count = 0
      @after_transmission_reports_count  = 0
      @removed_reports_count = 0
    end

    def remove(reports)
      removable_reports = @transmission.reports.merge(reports)

      @before_transmission_reports_count = @transmission.reports.count

      # FIXME: potential performances issues
      @removed_report_ids += removable_reports.ids

      removable_reports.update_all(transmission_id: nil)

      @after_transmission_reports_count = @transmission.reports.count
      @removed_reports_count            = @before_transmission_reports_count - @after_transmission_reports_count

      self
    end

    def removed_reports
      Report.where(id: @removed_report_ids)
    end
  end
end
