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
      intransmissibles_reports = @reports - transmissibles

      intransmissibles_reports.each_with_object({}) do |report, hash|
        if !report.completed?
          hash[report] = "Incomplet"
        elsif report.package.present?
          hash[report] = "Déjà transmis"
        elsif report.transmission.present?
          hash[report] = "Déjà dans la transmission en cours"
        end
      end
    end
  end
end
