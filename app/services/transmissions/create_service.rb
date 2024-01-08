# frozen_string_literal: true

module Transmissions
  class CreateService
    attr_reader :after_transmission_reports_count,
      :added_reports_count,
      :not_added_reports_count,
      :incomplete_reports_count,
      :transmitted_reports_count,
      :in_current_transmission_reports_count,
      :other_reason_count

    def initialize(transmission)
      @transmission                          = transmission
      @added_report_ids                      = []
      @before_transmission_reports_count     = 0
      @after_transmission_reports_count      = 0
      @transmissible_reports_count           = 0
      @intransmissible_reports_count         = 0
      @added_reports_count                   = 0
      @not_added_reports_count               = 0
      @incomplete_reports_count              = 0
      @transmitted_reports_count             = 0
      @in_current_transmission_reports_count = 0
      @other_reason_count                    = 0
    end

    def add(reports)
      transmissible_reports   = reports.transmissible
      intransmissible_reports = reports.where.not(id: transmissible_reports.select(:id))

      # TODO: potential performances issues
      @added_report_ids += transmissible_reports.ids

      calculate_before_counters(transmissible_reports, intransmissible_reports)
      transmissible_reports.update_all(transmission_id: @transmission.id)
      calculate_after_counters

      self
    end

    def added_reports
      Report.where(id: @added_report_ids)
    end

    def calculate_before_counters(transmissible_reports, intransmissible_reports)
      @before_transmission_reports_count     = @transmission.reports.count
      @transmissible_reports_count           = transmissible_reports.count

      @intransmissible_reports_count         = intransmissible_reports.count
      @incomplete_reports_count              = intransmissible_reports.draft.count
      @transmitted_reports_count             = intransmissible_reports.transmitted.count
      @in_current_transmission_reports_count = intransmissible_reports.in_transmission(@transmission).count
    end

    def calculate_after_counters
      @after_transmission_reports_count = @transmission.reports.count
      @added_reports_count              = @after_transmission_reports_count - @before_transmission_reports_count
      @other_reason_count               = @transmissible_reports_count - @added_reports_count
      @not_added_reports_count          = @other_reason_count + @intransmissible_reports_count
    end
  end
end
