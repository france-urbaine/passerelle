# frozen_string_literal: true

module Reports
  class CheckTransmissibilityService
    def initialize(reports, transmission_reports)
      @reports = reports
      @transmission_reports = transmission_reports
    end

    def transmissible_reports
      @reports.reject { |report| !report.transmissible? || @transmission_reports.include?(report) }
    end

    def intransmissible_reports
      @reports - transmissible_reports
    end

    def intransmissible_reports_by_reason
      result = { incomplete: [], transmitted: [], in_transmission: [] }

      intransmissible_reports.each do |report|
        if !report.completed?
          result[:incomplete] << report
        elsif report.package.present?
          result[:transmitted] << report
        elsif @transmission_reports.include?(report)
          result[:in_transmission] << report
        end
      end

      result
    end
  end
end
