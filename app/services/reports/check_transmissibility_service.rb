# frozen_string_literal: true

module Reports
  class CheckTransmissibilityService
    def initialize(reports)
      @reports = reports
    end

    def transmissibles
      @reports.select(&:transmissible?)
    end

    def intransmissibles
      intransmissibles_reports = @reports.reject(&:transmissible?)

      result = { incomplete: [], transmitted: [] }

      intransmissibles_reports.each do |report|
        if !report.completed?
          result[:incomplete] << report
        elsif report.package.present?
          result[:transmitted] << report
        end
      end

      result
    end
  end
end
