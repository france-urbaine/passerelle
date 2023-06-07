# frozen_string_literal: true

module Reports
  class CheckCompletenessService
    include ::ActiveModel::Model

    attr_reader :report

    delegate_missing_to :report

    def initialize(report)
      @report = report
      super()
    end

    validates_presence_of :code_insee
    validates_presence_of :date_constat

    with_options if: :require_situation_majic? do
      validates_presence_of :situation_annee_majic
      validates_presence_of :situation_invariant

      validates_presence_of :situation_proprietaire
      validates_presence_of :situation_numero_ordre_proprietaire

      validates_presence_of :situation_parcelle
      validates_presence_of :situation_libelle_voie
      validates_presence_of :situation_code_rivoli

      validates_presence_of :situation_numero_batiment
      validates_presence_of :situation_numero_escalier
      validates_presence_of :situation_numero_niveau
      validates_presence_of :situation_numero_porte
      validates_presence_of :situation_numero_ordre_porte

      validate :situation_adresse_must_be_complete
      validate :situation_porte_must_be_complete
      validate :situation_proprietaire_must_be_complete
    end

    with_options if: :require_situation_evaluatuation_hab? do
      validates_presence_of :situation_affectation
      validates_presence_of :situation_nature
      validates_presence_of :situation_categorie
      validates_presence_of :situation_surface_reelle
      validates_presence_of :situation_date_mutation
      validates_presence_of :situation_coefficient_entretien
    end

    with_options if: :require_proposition_evaluatuation_hab? do
      validates_presence_of :date_constat
      validates_presence_of :proposition_nature
      validates_presence_of :proposition_categorie
      validates_presence_of :proposition_surface_reelle
      validates_presence_of :proposition_coefficient_entretien
    end

    private

    def require_situation_majic?
      %w[evaluation_hab evaluation_eco].include?(action)
    end

    def require_situation_evaluatuation_hab?
      action == "evaluation_hab"
    end

    def require_proposition_evaluatuation_hab?
      action == "evaluation_hab"
    end

    SITUATION_ADDRESSE_ATTRIBUTES = %w[
      situation_numero_voie
      situation_indice_repetition
      situation_libelle_voie
      situation_code_rivoli
    ].freeze

    def situation_adresse_must_be_complete
      missing_attributes = SITUATION_ADDRESSE_ATTRIBUTES.select { |att| report[att].blank? }

      if missing_attributes == SITUATION_ADDRESSE_ATTRIBUTES
        errors.add(:situation_adresse, :blank)
      elsif missing_attributes.include?("situation_libelle_voie")
        errors.add(:situation_adresse, :incomplete_libelle_voie)
      elsif missing_attributes.include?("situation_code_rivoli")
        errors.add(:situation_adresse, :incomplete_code_rivoli)
      end
    end

    SITUATION_PORTE_ATTRIBUTES = %w[
      situation_numero_batiment
      situation_numero_escalier
      situation_numero_niveau
      situation_numero_porte
      situation_numero_ordre_porte
    ].freeze

    # We must create an accessor to render the error message
    attr_reader :situation_porte

    def situation_porte_must_be_complete
      missing_attributes = SITUATION_PORTE_ATTRIBUTES.select { |att| report[att].blank? }

      if missing_attributes == SITUATION_PORTE_ATTRIBUTES
        errors.add(:situation_porte, :blank)
      elsif missing_attributes.any?
        errors.add(:situation_porte, :incomplete)
      end
    end

    def situation_proprietaire_must_be_complete
      if situation_proprietaire.blank? && situation_numero_ordre_proprietaire?
        errors.add(:situation_proprietaire, :incomplete)
      elsif situation_proprietaire? && situation_numero_ordre_proprietaire.blank?
        errors.add(:situation_proprietaire, :incomplete_numero_ordre)
      end
    end
  end
end
