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

    FORM_TYPE_OPTIONS = [
      ["evaluation_local_habitation",    "Évaluation d'un local d'habitation",  { disabled: false }],
      ["evaluation_local_professionnel", "Évaluation d'un local professionnel", { disabled: true }],
      ["creation_local_habitation",      "Création d'un local d'habitation",    { disabled: true }],
      ["creation_local_professionnel",   "Création d'un local professionnel",   { disabled: true }],
      ["occupation_local_habitation",    "Occupation d'un local d'habitation",  { disabled: true }],
      ["occupation_local_professionnel", "Occupation d'un local professionnel", { disabled: true }]
    ].freeze

    def form_type_options
      FORM_TYPE_OPTIONS.map do |(key, name, options)|
        name = "(Bientôt disponible) #{name}" if options[:disabled]
        [name, key, options]
      end
    end
  end
end
