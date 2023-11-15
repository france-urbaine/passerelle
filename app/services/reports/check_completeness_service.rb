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
    validates_presence_of :code_insee
    validates_presence_of :date_constat

    # Situation MAJIC
    # --------------------------------------------------------------------------
    validates_presence_of :situation_annee_majic, if: :require_situation_annee_majic?
    validates_presence_of :situation_invariant,   if: :require_situation_invariant?
    validates_presence_of :situation_parcelle,    if: :require_situation_parcelle?

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

    # Situation evaluation
    # --------------------------------------------------------------------------
    validates_presence_of :situation_date_mutation,            if: :require_situation_date_mutation?
    validates_presence_of :situation_affectation,              if: :require_situation_affectation?
    validates_presence_of :situation_nature,                   if: :require_situation_nature?
    validates_presence_of :situation_categorie,                if: :require_situation_categorie?
    validates_presence_of :situation_surface_reelle,           if: :require_situation_surface_reelle?
    validates_presence_of :situation_coefficient_localisation, if: :require_situation_coefficient_localisation?
    validates_presence_of :situation_coefficient_entretien,    if: :require_situation_coefficient_entretien?

    with_options if: :require_situation_evaluation_habitation?, allow_blank: true do
      validates_inclusion_of :situation_nature,    in: :valid_local_habitation_natures
      validates_inclusion_of :situation_categorie, in: :valid_local_habitation_categories
    end

    with_options if: :require_situation_evaluation_professionnel?, allow_blank: true do
      validates_inclusion_of :situation_nature,    in: :valid_local_professionnel_natures
      validates_inclusion_of :situation_categorie, in: :valid_local_professionnel_categories
    end

    # Proposition evaluation
    # --------------------------------------------------------------------------
    validates_presence_of :proposition_affectation,              if: :require_proposition_affectation?
    validates_presence_of :proposition_nature,                   if: :require_proposition_nature?
    validates_presence_of :proposition_categorie,                if: :require_proposition_categorie?
    validates_presence_of :proposition_surface_reelle,           if: :require_proposition_surface_reelle?
    validates_presence_of :proposition_coefficient_entretien,    if: :require_proposition_coefficient_entretien?
    validates_presence_of :proposition_coefficient_localisation, if: :require_proposition_coefficient_localisation?

    with_options if: :require_proposition_evaluation_habitation?, allow_blank: true do
      validates_inclusion_of :proposition_nature,    in: :valid_local_habitation_natures
      validates_inclusion_of :proposition_categorie, in: :valid_local_habitation_categories
    end

    with_options if: :require_proposition_evaluation_professionnel?, allow_blank: true do
      validates_inclusion_of :proposition_nature,    in: :valid_local_professionnel_natures
      validates_inclusion_of :proposition_categorie, in: :valid_local_professionnel_categories
    end

    # TODO: creation_local_habitation => limiter les valeures possibles
    validates_presence_of :exonerations,             if: :require_proposition_exoneration?
    validates_presence_of :proposition_libelle_voie, if: :require_proposition_adresse?

    # Proposition creation
    # --------------------------------------------------------------------------
    validates_presence_of :proposition_nature_dependance, if: :require_proposition_nature_dependance?
    validates_presence_of :proposition_date_achevement,   if: :require_proposition_date_achevement?
    validates_presence_of :proposition_numero_permis,     if: :require_proposition_numero_permis?
    validates_presence_of :proposition_nature_travaux,    if: :require_proposition_nature_travaux?

    # Situation occupation
    # --------------------------------------------------------------------------
    validates_presence_of  :situation_occupation_annee,       if: :require_situation_occupation_annee?
    validates_presence_of  :situation_nature_occupation,      if: :require_situation_nature_occupation?
    validates_inclusion_of :situation_majoration_rs,          if: :require_situation_majoration_rs?, in: [true, false], message: :blank
    validates_presence_of  :situation_annee_cfe,              if: :require_situation_annee_cfe?
    validates_inclusion_of :situation_vacance_fiscale,        if: :require_situation_vacance_fiscale?, in: [true, false], message: :blank
    validates_presence_of  :situation_nombre_annees_vacance,  if: :require_situation_nombre_annees_vacance?
    validates_presence_of  :situation_siren_dernier_occupant, if: :require_situation_siren_dernier_occupant?
    validates_presence_of  :situation_nom_dernier_occupant,   if: :require_situation_nom_dernier_occupant?
    validates_presence_of  :situation_vlf_cfe,                if: :require_situation_vlf_cfe?
    validates_inclusion_of :situation_taxation_base_minimum,  if: :require_situation_taxation_base_minimum?, in: [true, false], message: :blank

    # Proposition occupation
    # --------------------------------------------------------------------------
    validates_presence_of  :proposition_nature_occupation,       if: :require_proposition_nature_occupation?
    validates_presence_of  :proposition_date_occupation,         if: :require_proposition_date_occupation?
    validates_inclusion_of :proposition_erreur_tlv,              if: :require_proposition_erreur_tlv?,      in: [true, false], message: :blank
    validates_inclusion_of :proposition_erreur_thlv,             if: :require_proposition_erreur_thlv?,     in: [true, false], message: :blank
    validates_inclusion_of :proposition_meuble_tourisme,         if: :require_proposition_meuble_tourisme?, in: [true, false], message: :blank
    validates_inclusion_of :proposition_majoration_rs,           if: :require_proposition_majoration_rs?,   in: [true, false], message: :blank
    validates_presence_of  :proposition_nom_occupant,            if: :require_proposition_nom_occupant?
    validates_presence_of  :proposition_prenom_occupant,         if: :require_proposition_prenom_occupant?
    validates_presence_of  :proposition_numero_siren,            if: :require_proposition_numero_siren?
    validates_presence_of  :proposition_nom_societe,             if: :require_proposition_nom_societe?
    validates_inclusion_of :proposition_etablissement_principal, if: :require_proposition_etablissement_principal?, in: [true, false], message: :blank
    validates_inclusion_of :proposition_chantier_longue_duree,   if: :require_proposition_chantier_longue_duree?,   in: [true, false], message: :blank
    validates_presence_of  :proposition_code_naf,                if: :require_proposition_code_naf?
    validates_presence_of  :proposition_date_debut_activite,     if: :require_proposition_date_debut_activite?

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
      valid_local_professionnel_categories: "enum.local_professionnel_categorie",
      valid_local_habitation_occupations:   "enum.local_habitation_occupation"
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
