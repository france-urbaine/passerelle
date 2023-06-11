# frozen_string_literal: true

module Reports
  class CreateFormService
    # Use proper names and keys in form builders
    def self.model_name
      Report.model_name
    end

    attr_reader :report

    delegate_missing_to :report

    def initialize(report)
      @report = report
    end

    SUBJECT_OPTIONS = [
      ["Évaluation de locaux d'habitation", [
        ["Problème d'évaluation d'un local d'habitation",   "evaluation_hab/evaluation",         { disabled: false }],
        ["Problème d'adresse d'un local d'habitation",      "evaluation_hab/adresse",            { disabled: false }],
        ["Problème d'exonération d'un local d'habitation",  "evaluation_hab/exoneration",        { disabled: true }],
        ["Problème d'affectation d'un local d'habitation",  "evaluation_hab/affectation",        { disabled: true }],
        ["Omission bâtie sur un local d'habitation",        "evaluation_hab/omission_batie",     { disabled: true }],
        ["Achèvement de travaux sur un local d'habitation", "evaluation_hab/achevement_travaux", { disabled: true }]
      ]],
      ["Évaluation de locaux professionnels", [
        ["Problème d'exonération d'un local professionnel",  "evaluation_pro/evaluation",         { disabled: true }],
        ["Problème d'évaluation d'un local professionnel",   "evaluation_pro/exoneration",        { disabled: true }],
        ["Problème d'affectation d'un local professionnel",  "evaluation_pro/affectation",        { disabled: true }],
        ["Problème d'adresse d'un local professionnel",      "evaluation_pro/adresse",            { disabled: true }],
        ["Omission bâtie sur un local professionnel",        "evaluation_pro/omission_batie",     { disabled: true }],
        ["Achèvement de travaux sur un local professionnel", "evaluation_pro/achevement_travaux", { disabled: true }]
      ]]
    ].freeze

    def subject_options
      SUBJECT_OPTIONS.map do |(group_name, group)|
        group = group.map do |(name, key, options)|
          name = "(Bientôt disponible) #{name}" if options[:disabled]
          [name, key, options]
        end

        [group_name, group]
      end
    end
  end
end
