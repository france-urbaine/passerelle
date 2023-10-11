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
      transmissible_reports   = transmissible_reports(reports)
      intransmissible_reports = reports - transmissible_reports

      calculate_before_counters(transmissible_reports, intransmissible_reports)
      transmissible_reports.update_all(transmission_id: @transmission.id)
      calculate_after_counters

      self
    end

    def transmissible_reports(reports)
      reports.where(<<~SQL.squish)
            completed_at IS NOT NULL
        AND package_id IS NULL
        AND (reports.transmission_id != '#{@transmission.id}' OR reports.transmission_id IS NULL)
      SQL
    end

    def calculate_before_counters(transmissible_reports, intransmissible_reports)
      @before_transmission_reports_count = @transmission.reports.count
      @transmissible_reports_count       = transmissible_reports.count
      @intransmissible_reports_count     = intransmissible_reports.count

      calculate_intransmissible_reason_counters(intransmissible_reports)
    end

    def calculate_intransmissible_reason_counters(intransmissible_reports)
      intransmissible_reports.each do |report|
        if !report.completed?
          @incomplete_reports_count += 1
        elsif report.package.present?
          @transmitted_reports_count += 1
        elsif @transmission.reports.include?(report)
          @in_current_transmission_reports_count += 1
        end
      end
    end

    def calculate_after_counters
      @after_transmission_reports_count = @transmission.reports.count
      @added_reports_count              = @after_transmission_reports_count - @before_transmission_reports_count
      @other_reason_count               = @transmissible_reports_count - @added_reports_count
      @not_added_reports_count          = @other_reason_count + @intransmissible_reports_count
    end
  end
end
