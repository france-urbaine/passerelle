# frozen_string_literal: true

module Reports
  class RequirementsService
    include ::ActiveModel::Model

    attr_reader :report

    def initialize(report)
      @report = report
      super()
    end

    def respond_to_predicate?(method, *)
      method.match?(/^(require|display|is)_.*\?$/) && respond_to?(method)
    end

    # Requirements for current MAJIC situation
    # --------------------------------------------------------------------------
    concerning :SituationMajic do
      # This fieldset is displayed for:
      # * any `evaluation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_majic?
        evaluation_local? || occupation_local?
      end

      # @attribute situation_annee_majic
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_annee_majic?
        evaluation_local? || occupation_local?
      end

      def require_situation_annee_majic?
        display_situation_annee_majic?
      end

      # @attribute situation_invariant
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_invariant?
        evaluation_local? || occupation_local?
      end

      def require_situation_invariant?
        display_situation_invariant?
      end

      # @attribute situation_parcelle
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form
      # * any `creation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_parcelle?
        evaluation_local? || creation_local? || occupation_local?
      end

      def require_situation_parcelle?
        display_situation_parcelle?
      end

      # @attribute situation_libelle_voie
      # @attribute situation_code_rivoli
      #
      # These attributes are displayed and required for:
      # * any `evaluation_local_*` form
      # * any `creation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_adresse?
        evaluation_local? || creation_local? || occupation_local?
      end

      def require_situation_adresse?
        display_situation_adresse?
      end

      # @attribute situation_numero_batiment
      # @attribute situation_numero_escalier
      # @attribute situation_numero_niveau
      # @attribute situation_numero_porte
      # @attribute situation_numero_ordre_porte
      #
      # These attributes are displayed and required for:
      # * any `evaluation_local_*` form
      # * any `occupation_local_*` form
      #
      def display_situation_porte?
        evaluation_local? || occupation_local?
      end

      def require_situation_porte?
        display_situation_porte?
      end

      # @attribute situation_proprietaire
      # @attribute situation_numero_ordre_proprietaire
      #
      # These attributes are displayed for:
      # * any `evaluation_local_*` form
      # * any `creation_local_*` form
      # * any `occupation_local_*` form
      #
      # They are required except for:
      # * any `occupation_local_*` form
      #
      def display_situation_proprietaire?
        evaluation_local? || creation_local? || occupation_local?
      end

      def require_situation_proprietaire?
        display_situation_proprietaire? && !occupation_local?
      end
    end

    # Requirements for current evaluation
    # --------------------------------------------------------------------------
    concerning :SituationEvaluation do
      # This fieldset is displayed for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      # * any `occupation_local_*` form
      #
      def display_situation_evaluation?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      # This fieldset must be evaluatated as an habitation or a professional local
      #
      def require_situation_evaluation_habitation?
        evaluation_local_habitation_with_any_anomaly_but_address? || form_type == "occupation_local_habitation"
      end

      def require_situation_evaluation_professionnel?
        evaluation_local_professionnel_with_any_anomaly_but_address? || form_type == "occupation_local_professionnel"
      end

      # @attribute situation_date_mutation
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      #
      def display_situation_date_mutation?
        evaluation_local_with_any_anomaly_but_address?
      end

      def require_situation_date_mutation?
        display_situation_date_mutation?
      end

      # @attribute situation_affectation
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      # * any `occupation_local_*` form
      #
      def display_situation_affectation?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      def require_situation_affectation?
        display_situation_affectation?
      end

      # @attribute situation_nature
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      # * any `occupation_local_*` form
      #
      def display_situation_nature?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      def require_situation_nature?
        display_situation_nature?
      end

      # @attribute situation_categorie
      #
      # This attribute is displayed for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      # * any `occupation_local_*` form
      #
      # It is required except for:
      # * any `evaluation_local_*` form with an "industrial" nature
      #
      def display_situation_categorie?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      def require_situation_categorie?
        display_situation_categorie? && !situation_nature_industrial?
      end

      # @attribute situation_surface_reelle
      #
      # This attribute is displayed for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      # * any `occupation_local_*` form
      #
      # It is required except for:
      # * any `evaluation_local_*` form with an "industrial" nature
      # * any `occupation_local_habitation` form
      #
      def display_situation_surface_reelle?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      def require_situation_surface_reelle?
        display_situation_surface_reelle? && !(
          situation_nature_industrial? ||
          occupation_local_habitation?
        )
      end

      # @attribute situation_surface_p1
      # @attribute situation_surface_p2
      # @attribute situation_surface_p3
      # @attribute situation_surface_pk1
      # @attribute situation_surface_pk2
      # @attribute situation_surface_ponderee
      #
      # These attributes are displayed for:
      # * any `evaluation_local_pro` form with any anomalies but `adresse`
      #
      # They are never required.
      #
      def display_other_situation_surface?
        evaluation_local_professionnel_with_any_anomaly_but_address?
      end

      # @attribute situation_coefficient_localisation
      #
      # This attribute is displayed for:
      # * any `evaluation_local_pro` form with any anomalies but `adresse`
      #
      # It is required except for:
      # * an "industrial" nature
      #
      def display_situation_coefficient_localisation?
        evaluation_local_professionnel_with_any_anomaly_but_address?
      end

      def require_situation_coefficient_localisation?
        display_situation_coefficient_localisation? && !situation_nature_industrial?
      end

      # @attribute situation_coefficient_entretien
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_hab` form with any anomalies but `adresse`
      #
      def display_situation_coefficient_entretien?
        evaluation_local_habitation_with_any_anomaly_but_address?
      end

      def require_situation_coefficient_entretien?
        display_situation_coefficient_entretien?
      end

      # @attribute situation_coefficient_situation_generale
      # @attribute situation_coefficient_situation_particuliere
      #
      # These attributes are displayed or:
      # * any `evaluation_local_hab` form with any anomalies but `adresse`
      #
      # They are never required.
      #
      def display_situation_coefficient_situation?
        evaluation_local_habitation_with_any_anomaly_but_address?
      end
    end

    # Requirements for new evaluation
    # --------------------------------------------------------------------------
    concerning :PropositionEvaluation do
      # This fieldset is displayed for:
      # * any `evaluation_local_*` form with any anomalies but `adresse`
      #
      def display_proposition_evaluation?
        evaluation_local_with_any_anomaly_but_address?
      end

      # This fieldset must be evaluatated as an habitation or a professional local
      #
      def require_proposition_evaluation_habitation?
        @require_proposition_evaluation_habitation ||=
          case form_type
          when "evaluation_local_habitation"
            (anomalies.include?("affectation") && proposition_affectation_habitation?) ||
            (anomalies.exclude?("affectation") && anomalies.intersect?(%w[consistance correctif]))
          when "evaluation_local_professionnel"
            anomalies.include?("affectation") && proposition_affectation_habitation?
          end
      end

      def require_proposition_evaluation_professionnel?
        @require_proposition_evaluation_professionnel ||=
          case form_type
          when "evaluation_local_professionnel"
            (anomalies.include?("affectation") && proposition_affectation_professionnel?) ||
            (anomalies.exclude?("affectation") && anomalies.intersect?(%w[consistance categorie]))
          when "evaluation_local_habitation"
            anomalies.include?("affectation") && proposition_affectation_professionnel?
          end
      end

      # @attribute proposition_affectation
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with the anomaly `affectation`
      #
      def display_proposition_affectation?
        evaluation_local? &&
          anomalies.include?("affectation")
      end

      def require_proposition_affectation?
        display_proposition_affectation?
      end

      # @attribute proposition_nature
      #
      # This attribute is displayed and required for:
      # * any `creation_local_*`
      # * any `evaluation_local_*` form with the anomaly `affectation`
      # * any `evaluation_local_habitation` form with the anomalies `consistance` or `categorie`
      #
      def display_proposition_nature?
        creation_local? || (
          evaluation_local? && anomalies.include?("affectation")
        ) || (
          form_type == "evaluation_local_habitation" && anomalies.intersect?(%w[consistance categorie])
        )
      end

      def require_proposition_nature?
        display_proposition_nature?
      end

      # @attribute proposition_categorie
      #
      # This attribute is displayed for:
      # * any `creation_local_*`
      # * any `evaluation_local_*` form with the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute required except for:
      # * any `creation_local_*` form with 'industrial' nature
      # * any `evaluation_local_*` form that has changed to or remained on an "industrial" nature
      #
      def display_proposition_categorie?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_categorie?
        display_proposition_categorie? &&
          !creation_local_industrial? &&
          !evaluation_local_with_nature_changed_to_industrial? &&
          !evaluation_local_with_nature_remained_to_industrial?
      end

      # @attribute proposition_surface_reelle
      #
      # This attribute is displayed for:
      # * any `creation_local_*`
      # * any `evaluation_local_*` form with the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute required except for:
      # * any `creation_local_*` form with 'industrial' nature
      # * any `evaluation_local_*` form that has changed to or remained on an "industrial" nature
      #
      def display_proposition_surface_reelle?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_surface_reelle?
        display_proposition_surface_reelle? &&
          !creation_local_industrial? &&
          !evaluation_local_with_nature_changed_to_industrial? &&
          !evaluation_local_with_nature_remained_to_industrial?
      end

      # @attribute proposition_surface_p1
      # @attribute proposition_surface_p2
      # @attribute proposition_surface_p3
      # @attribute proposition_surface_pk1
      # @attribute proposition_surface_pk2
      # @attribute proposition_surface_ponderee
      #
      # These attributes are displayed for:
      # * any `evaluation_local_*` form that propose a "professional" evaluation
      #
      # They are never required.
      #
      def display_other_proposition_surface?
        require_proposition_evaluation_professionnel?
      end

      # @attribute proposition_coefficient_localisation
      #
      # This attribute is displayed for:
      # * any `evaluation_local_*` form that propose a "professional" evaluation
      #
      # This attribute is required except for:
      # * any `evaluation_local_*` form that has changed to or remained on an "industrial" nature
      #
      def display_proposition_coefficient_localisation?
        require_proposition_evaluation_professionnel?
      end

      def require_proposition_coefficient_localisation?
        display_proposition_coefficient_localisation? &&
          !evaluation_local_with_nature_changed_to_industrial? &&
          !evaluation_local_with_nature_remained_to_industrial?
      end

      # @attribute proposition_coefficient_entretien
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form that propose an "habitation" evaluation
      #
      def display_proposition_coefficient_entretien?
        require_proposition_evaluation_habitation?
      end

      def require_proposition_coefficient_entretien?
        display_proposition_coefficient_entretien?
      end

      # @attribute proposition_coefficient_situation_generale
      # @attribute proposition_coefficient_situation_particuliere
      #
      # These attributes are displayed for:
      # * any `evaluation_local_*` form that propose an "habitation" evaluation
      #
      # They are never required.
      #
      def display_proposition_coefficient_situation?
        require_proposition_evaluation_habitation?
      end

      # @attribute exonerations_attributes
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with the anomaly `exoneration`
      #
      def display_proposition_exoneration?
        evaluation_local? && anomalies.include?("exoneration")
      end

      def require_proposition_exoneration?
        display_proposition_exoneration?
      end

      # @attribute proposition_libelle_voie
      #
      # This attribute is displayed and required for:
      # * any `evaluation_local_*` form with the anomaly `adresse`
      #
      def display_proposition_adresse?
        evaluation_local? && anomalies.include?("adresse")
      end

      def require_proposition_adresse?
        display_proposition_adresse?
      end
    end

    # Requirements for new buildings
    # --------------------------------------------------------------------------
    concerning :PropositionCreation do
      # This fieldset is displayed for:
      # * any `creation_local_*` form
      #
      def display_proposition_creation_local?
        creation_local?
      end

      # @attribute proposition_nature_dependance
      #
      # This attribute is displayed and required for:
      # * any 'creation_local_habitation' form with a "dependency" nature
      #
      def display_proposition_nature_dependance?
        form_type == "creation_local_habitation" &&
          %w[DA DM].include?(@report.proposition_nature)
      end

      def require_proposition_nature_dependance?
        display_proposition_nature_dependance?
      end

      # @attribute proposition_date_achevement
      #
      # This attribute is displayed and required for:
      # * any 'creation_local_*' form
      #
      def display_proposition_date_achevement?
        creation_local?
      end

      def require_proposition_date_achevement?
        display_proposition_date_achevement?
      end

      # @attribute proposition_numero_permis
      #
      # This attribute is displayed and required for:
      # * any 'creation_local_*' form with the anomaly `construction_neuve``
      #
      def display_proposition_numero_permis?
        creation_local? && anomalies.include?("construction_neuve")
      end

      def require_proposition_numero_permis?
        display_proposition_numero_permis?
      end

      # @attribute proposition_nature_travaux
      #
      # This attribute is displayed and required for:
      # * any 'creation_local_*' form with the anomaly `construction_neuve``
      #
      def display_proposition_nature_travaux?
        creation_local? && anomalies.include?("construction_neuve")
      end

      def require_proposition_nature_travaux?
        display_proposition_nature_travaux?
      end
    end

    # Requirements for occupations
    # --------------------------------------------------------------------------
    concerning :SituationOccupation do
      # This fieldset is displayed for:
      # * any `occupation_local_*` form
      #
      def display_situation_occupation?
        occupation_local?
      end

      # This fieldset must be evaluatated as an habitation or a professional occupation
      #
      def require_situation_occupation_habitation?
        occupation_local_habitation?
      end

      def require_situation_occupation_professionnel?
        occupation_local_professionnel?
      end

      # @attribute situation_nature_occupation
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form
      #
      def display_situation_nature_occupation?
        occupation_local_habitation?
      end

      def require_situation_nature_occupation?
        display_situation_nature_occupation?
      end

      # @attribute situation_majoration_rs
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `situation_nature_occupation`
      #   to `RS` ("résidence secondaire")
      #
      def display_situation_majoration_rs?
        occupation_local_habitation? && @report.situation_nature_occupation == "RS"
      end

      def require_situation_majoration_rs?
        display_situation_majoration_rs?
      end

      # @attribute situation_annee_cfe
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_annee_cfe?
        occupation_local_professionnel?
      end

      def require_situation_annee_cfe?
        display_situation_annee_cfe?
      end

      # @attribute situation_vacance_fiscale
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_vacance_fiscale?
        occupation_local_professionnel?
      end

      def require_situation_vacance_fiscale?
        display_situation_vacance_fiscale?
      end

      # @attribute situation_nombre_annees_vacance
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form that has set `situation_vacance_fiscale` to `true`
      #
      def display_situation_nombre_annees_vacance?
        occupation_local_professionnel? && @report.situation_vacance_fiscale?
      end

      def require_situation_nombre_annees_vacance?
        display_situation_nombre_annees_vacance?
      end

      # @attribute situation_siren_dernier_occupant
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_siren_dernier_occupant?
        occupation_local_professionnel?
      end

      def require_situation_siren_dernier_occupant?
        display_situation_siren_dernier_occupant?
      end

      # @attribute situation_nom_dernier_occupant
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_nom_dernier_occupant?
        occupation_local_professionnel?
      end

      def require_situation_nom_dernier_occupant?
        display_situation_nom_dernier_occupant?
      end

      # @attribute situation_vlf_cfe
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_vlf_cfe?
        occupation_local_professionnel?
      end

      def require_situation_vlf_cfe?
        display_situation_vlf_cfe?
      end

      # @attribute situation_taxation_base_minimum
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_situation_taxation_base_minimum?
        occupation_local_professionnel?
      end

      def require_situation_taxation_base_minimum?
        display_situation_taxation_base_minimum?
      end
    end

    concerning :PropostionOccupation do
      # This fieldset is displayed for:
      # * any `occupation_local_*` form
      #
      def display_proposition_occupation?
        occupation_local?
      end

      def require_proposition_occupation_habitation?
        occupation_local_habitation?
      end

      def require_proposition_occupation_professionnel?
        occupation_local_professionnel?
      end

      # @attribute proposition_occupation_annee
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form
      #
      def display_proposition_occupation_annee?
        occupation_local_habitation?
      end

      def require_proposition_occupation_annee?
        display_proposition_occupation_annee?
      end

      # @attribute proposition_nature_occupation
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form
      #
      def display_proposition_nature_occupation?
        occupation_local_habitation?
      end

      def require_proposition_nature_occupation?
        display_proposition_nature_occupation?
      end

      # @attribute proposition_date_occupation
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form
      #
      def display_proposition_date_occupation?
        occupation_local_habitation?
      end

      def require_proposition_date_occupation?
        display_proposition_date_occupation?
      end

      # @attribute proposition_erreur_tlv
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `situation_nature_occupation` to `vacant_tlv`
      #
      def display_proposition_erreur_tlv?
        occupation_local_habitation? && @report.situation_nature_occupation == "vacant_tlv"
      end

      def require_proposition_erreur_tlv?
        display_proposition_erreur_tlv?
      end

      # @attribute proposition_erreur_thlv
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `situation_nature_occupation` to `vacant_thlv`
      #
      def display_proposition_erreur_thlv?
        occupation_local_habitation? && @report.situation_nature_occupation == "vacant_thlv"
      end

      def require_proposition_erreur_thlv?
        display_proposition_erreur_thlv?
      end

      # @attribute proposition_meuble_tourisme
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `proposition_nature_occupation` to a non-vacant state.
      #
      def display_proposition_meuble_tourisme?
        occupation_local_habitation? && %w[RP RS RE].include?(@report.proposition_nature_occupation)
      end

      def require_proposition_meuble_tourisme?
        display_proposition_meuble_tourisme?
      end

      # @attribute proposition_majoration_rs
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `proposition_nature_occupation`
      #   to `RS` ("résidence secondaire")
      #
      def display_proposition_majoration_rs?
        occupation_local_habitation? && @report.proposition_nature_occupation == "RS"
      end

      def require_proposition_majoration_rs?
        display_proposition_majoration_rs?
      end

      # @attribute proposition_nom_occupant
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `proposition_nature_occupation` to a non-vacant state.
      #
      def display_proposition_nom_occupant?
        occupation_local_habitation? && %w[RP RS RE].include?(@report.proposition_nature_occupation)
      end

      def require_proposition_nom_occupant?
        display_proposition_nom_occupant?
      end

      # @attribute proposition_prenom_occupant
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_habitation` form that has set `proposition_nature_occupation` to a non-vacant state.
      #
      def display_proposition_prenom_occupant?
        occupation_local_habitation? && %w[RP RS RE].include?(@report.proposition_nature_occupation)
      end

      def require_proposition_prenom_occupant?
        display_proposition_prenom_occupant?
      end

      # @attribute proposition_adresse_occupant
      #
      # This attribute is displayed for:
      # * any `occupation_local_habitation` form that has set `proposition_nature_occupation` to a non-vacant state.
      #
      # It is never required.
      #
      def display_proposition_adresse_occupant?
        occupation_local_habitation? && %w[RP RS RE].include?(@report.proposition_nature_occupation)
      end

      # @attribute proposition_numero_siren
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_numero_siren?
        occupation_local_professionnel?
      end

      def require_proposition_numero_siren?
        display_proposition_numero_siren?
      end

      # @attribute proposition_nom_societe
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_nom_societe?
        occupation_local_professionnel?
      end

      def require_proposition_nom_societe?
        display_proposition_nom_societe?
      end

      # @attribute proposition_nom_enseigne
      #
      # This attribute is displayed for:
      # * any `occupation_local_professionnel` form
      #
      # It is never required.
      #
      def display_proposition_nom_enseigne?
        occupation_local_professionnel?
      end

      # @attribute proposition_etablissement_principal
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_etablissement_principal?
        occupation_local_professionnel?
      end

      def require_proposition_etablissement_principal?
        display_proposition_etablissement_principal?
      end

      # @attribute proposition_chantier_longue_duree
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_chantier_longue_duree?
        occupation_local_professionnel?
      end

      def require_proposition_chantier_longue_duree?
        display_proposition_chantier_longue_duree?
      end

      # @attribute proposition_code_naf
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_code_naf?
        occupation_local_professionnel?
      end

      def require_proposition_code_naf?
        display_proposition_code_naf?
      end

      # @attribute proposition_date_debut_activite
      #
      # This attribute is displayed and required for:
      # * any `occupation_local_professionnel` form
      #
      def display_proposition_date_debut_activite?
        occupation_local_professionnel?
      end

      def require_proposition_date_debut_activite?
        display_proposition_date_debut_activite?
      end
    end

    # --------------------------------------------------------------------------
    private

    delegate :form_type, :anomalies, to: :report

    def evaluation_local?
      @evaluation_local ||= form_type.start_with?("evaluation_local_")
    end

    def evaluation_local_with_any_anomaly_but_address?
      @evaluation_local_with_any_anomaly_but_address ||=
        evaluation_local? &&
        anomalies.intersect?(%w[affectation categorie consistance correctif exoneration])
    end

    def evaluation_local_habitation_with_any_anomaly_but_address?
      @evaluation_local_habitation_with_any_anomaly_but_address ||=
        form_type == "evaluation_local_habitation" &&
        anomalies.intersect?(%w[affectation consistance correctif exoneration])
    end

    def evaluation_local_professionnel_with_any_anomaly_but_address?
      @evaluation_local_professionnel_with_any_anomaly_but_address ||=
        form_type == "evaluation_local_professionnel" &&
        anomalies.intersect?(%w[affectation consistance categorie exoneration])
    end

    def evaluation_local_with_nature_changed_to_industrial?
      evaluation_local? && anomalies.include?("affectation") && proposition_nature_industrial?
    end

    def evaluation_local_with_nature_remained_to_industrial?
      evaluation_local? && anomalies.intersect?(%w[consistance categorie exoneration]) && situation_nature_industrial?
    end

    def creation_local?
      @creation_local ||= form_type.start_with?("creation_local_")
    end

    def creation_local_industrial?
      creation_local? && proposition_nature_industrial?
    end

    def proposition_affectation_habitation?
      @proposition_affectation_habitation ||= I18n.t("enum.local_habitation_affectation")
        .keys
        .map(&:to_s)
        .include?(@report.proposition_affectation)
    end

    def proposition_affectation_professionnel?
      @proposition_affectation_professionnel ||= I18n.t("enum.local_professionnel_affectation")
        .keys
        .map(&:to_s)
        .include?(@report.proposition_affectation)
    end

    def situation_nature_industrial?
      @report.situation_nature == "U"
    end

    def proposition_nature_industrial?
      @report.proposition_nature == "U"
    end

    def occupation_local?
      @occupation_local ||= form_type.start_with?("occupation_local_")
    end

    def occupation_local_habitation?
      @occupation_local_habitation ||= form_type == "occupation_local_habitation"
    end

    def occupation_local_professionnel?
      @occupation_local_professionnel ||= form_type == "occupation_local_professionnel"
    end
  end
end
