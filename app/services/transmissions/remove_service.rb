# frozen_string_literal: true

module Transmissions
  class RemoveService
    attr_reader :removed_reports_count, :after_transmission_reports_count

    def initialize(transmission)
      @transmission                      = transmission
      @before_transmission_reports_count = 0
      @after_transmission_reports_count  = 0
      @removed_reports_count = 0
    end

    def remove(reports)
      @before_transmission_reports_count = @transmission.reports.count
      removable_reports                  = @transmission.reports.where(id: reports.ids)

      removable_reports.update_all(transmission_id: nil)

      @after_transmission_reports_count = @transmission.reports.count
      @removed_reports_count            = @before_transmission_reports_count - @after_transmission_reports_count

      self
    end
  end
end
