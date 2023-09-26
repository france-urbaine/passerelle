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

      intransmissibles_hash = {}

      intransmissibles_reports.each do |report|
        if !report.completed?
          intransmissibles_hash[report] = "Incomplet"
        elsif report.package.present?
          intransmissibles_hash[report] = "Déjà transmis"
        elsif report.transmission.present?
          intransmissibles_hash[report] = "Déjà dans la transmission en cours"
        end
      end

      intransmissibles_hash
    end
  end
end
