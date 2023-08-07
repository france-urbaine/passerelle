# frozen_string_literal: true

module Reports
  class CheckCompletenessService
    include ::ActiveModel::Model

    attr_reader :report

    def initialize(report)
      @report = report
      super()
    end

    validates_presence_of :anomalies
    validates_presence_of :anomalies
    validates_presence_of :code_insee
    validates_presence_of :date_constat

    with_options if: :require_situation_majic? do
      validates_presence_of :situation_annee_majic
      validates_presence_of :situation_invariant
    end

    with_options if: :require_situation_parcelle? do
      validates_presence_of :situation_parcelle
    end

    with_options if: :require_situation_adresse? do
      validates_presence_of :situation_libelle_voie
      validates_presence_of :situation_code_rivoli
      validate :situation_adresse_must_be_complete
    end

    with_options if: :require_situation_porte? do
      validates_presence_of :situation_numero_batiment
      validates_presence_of :situation_numero_escalier
      validates_presence_of :situation_numero_niveau
      validates_presence_of :situation_numero_porte
      validates_presence_of :situation_numero_ordre_porte
      validate :situation_porte_must_be_complete
    end

    with_options if: :require_situation_proprietaire? do
      validates_presence_of :situation_proprietaire
      validates_presence_of :situation_numero_ordre_proprietaire
      validate :situation_proprietaire_must_be_complete
    end

    with_options if: :require_situation_evaluation? do
      validates_presence_of :situation_date_mutation
      validates_presence_of :situation_affectation
      validates_presence_of :situation_nature
    end

    validates_presence_of :situation_categorie,                if: :require_situation_categorie?
    validates_presence_of :situation_surface_reelle,           if: :require_situation_surface?
    validates_presence_of :situation_coefficient_localisation, if: :require_situation_coefficient_localisation?
    validates_presence_of :situation_coefficient_entretien,    if: :require_situation_evaluation_habitation?

    with_options if: :require_situation_evaluation_habitation?, allow_blank: true do
      validates_inclusion_of :situation_nature,    in: :valid_local_habitation_natures
      validates_inclusion_of :situation_categorie, in: :valid_local_habitation_categories
    end

    with_options if: :require_situation_evaluation_professionnel?, allow_blank: true do
      validates_inclusion_of :situation_nature,    in: :valid_local_professionnel_natures
      validates_inclusion_of :situation_categorie, in: :valid_local_professionnel_categories
    end

    validates_presence_of :proposition_affectation,              if: :require_proposition_affectation?
    validates_presence_of :proposition_nature,                   if: :require_proposition_nature?
    validates_presence_of :proposition_nature_dependance,        if: :require_proposition_nature_dependance?
    validates_presence_of :proposition_categorie,                if: :require_proposition_categorie?
    validates_presence_of :proposition_surface_reelle,           if: :require_proposition_surface?
    validates_presence_of :proposition_coefficient_entretien,    if: :require_proposition_correctif?
    validates_presence_of :proposition_coefficient_localisation, if: :require_proposition_coefficient_localisation?

    with_options if: :require_proposition_evaluation_habitation?, allow_blank: true do
      validates_inclusion_of :proposition_nature,    in: :valid_local_habitation_natures
      validates_inclusion_of :proposition_categorie, in: :valid_local_habitation_categories
    end

    with_options if: :require_proposition_evaluation_professionnel?, allow_blank: true do
      validates_inclusion_of :proposition_nature,    in: :valid_local_professionnel_natures
      validates_inclusion_of :proposition_categorie, in: :valid_local_professionnel_categories
    end

    with_options if: :require_proposition_exoneration? do
      validates_presence_of :exonerations
    end

    with_options if: :require_proposition_adresse? do
      validates_presence_of :proposition_libelle_voie
    end

    with_options if: :require_proposition_date_achevement? do
      validates_presence_of :proposition_date_achevement
    end

    with_options if: :require_proposition_construction_neuve? do
      validates_presence_of :proposition_numero_permis
      validates_presence_of :proposition_nature_travaux
    end

    private

    delegate :exonerations, to: :report

    def requirements
      @requirements ||= Reports::RequirementsService.new(@report)
    end

    def respond_to_missing?(method, *)
      requirements.respond_to_predicate?(method) || missing_attribute_method?(method) || super
    end

    def method_missing(method, *)
      if requirements.respond_to_predicate?(method)
        requirements.public_send(method, *)
      elsif missing_attribute_method?(method)
        report.public_send(method, *)
      else
        super
      end
    end

    def missing_attribute_method?(method)
      return false unless method =~ /^([a-z]\w+)(=|\?)?$/

      report.class.column_names.include?(::Regexp.last_match(1))
    end

    {
      valid_local_habitation_natures:       "enum.local_habitation_nature",
      valid_local_professionnel_natures:    "enum.local_professionnel_nature",
      valid_local_habitation_categories:    "enum.local_habitation_categorie",
      valid_local_professionnel_categories: "enum.local_professionnel_categorie"
    }.each do |method_name, enum_key|
      define_method method_name do
        I18n.t(enum_key).keys.map(&:to_s)
      end
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
