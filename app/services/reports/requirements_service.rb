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
      # * every `evaluation_local_*` form
      # * every `occupation_local_*` form
      #
      def display_situation_majic?
        evaluation_local? || occupation_local?
      end

      # @attribute situation_annee_majic
      #
      # This attribute is displayed and required for:
      # * every `evaluation_local_*` form
      # * every `occupation_local_*` form
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
      # * every `evaluation_local_*` form
      # * every `occupation_local_*` form
      #
      def display_situation_invariant?
        evaluation_local? || occupation_local?
      end

      def require_situation_invariant?
        display_situation_invariant?
      end

      # @attribute situation_parcelle
      #
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form
      # * every `creation_local_*` form
      # * every `occupation_local_*` form
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
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form
      # * every `creation_local_*` form
      # * every `occupation_local_*` form
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
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form
      # * every `occupation_local_*` form
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
      # This fieldset is displayed for:
      # * every `evaluation_local_*` form
      # * every `creation_local_*` form
      # * every `occupation_local_*` form
      #
      # This attribute is always required except for:
      # * every `occupation_local_*` form
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
      # * every `evaluation_local_*` form with any anomalies but address
      # * every `occupation_local_*` form
      #
      def display_situation_evaluation?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      # This fieldset is evaluatation as an habitation of a professional local
      #
      def require_situation_evaluation_habitation?
        evaluation_local_habitation_with_any_anomaly_but_address? || form_type == "occupation_local_habitation"
      end

      def require_situation_evaluation_professionnel?
        evaluation_local_professionnel_with_any_anomaly_but_address? || form_type == "occupation_local_professionnel"
      end

      # @attribute situation_date_mutation
      #
      # This attribute is only displayed and required for:
      # * every `evaluation_local_*` form with any anomalies but address
      #
      def display_situation_date_mutation?
        evaluation_local_with_any_anomaly_but_address?
      end

      def require_situation_date_mutation?
        display_situation_date_mutation?
      end

      # @attribute situation_affectation
      #
      # This attribute is always displayed and required on the fieldset.
      #
      def display_situation_affectation?
        display_situation_evaluation?
      end

      def require_situation_affectation?
        display_situation_affectation?
      end

      # @attribute situation_nature
      #
      # This attribute is always displayed and required on the fieldset.
      #
      def display_situation_nature?
        display_situation_evaluation?
      end

      def require_situation_nature?
        display_situation_nature?
      end

      # @attribute situation_categorie
      #
      # This attribute is always displayed on this fieldset except for:
      # * an "industrial" nature is selected
      #
      def display_situation_categorie?
        display_situation_evaluation?
      end

      def require_situation_categorie?
        display_situation_categorie? && !situation_nature_industriel?
      end

      # @attribute situation_surface_reelle
      #
      # This attribute is always displayed on this fieldset except for:
      # * an "industrial" nature is selected
      # * a `occupation_local_habitation` form
      #
      def display_situation_surface_reelle?
        display_situation_evaluation?
      end

      def require_situation_surface_reelle?
        display_situation_surface_reelle? && !(
          situation_nature_industriel? ||
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
      # Other `situation_surface_*` attributes are displayed for:
      # * every `evaluation_local_pro` form with any anomalies but address
      #
      # They are never required.
      #
      def display_other_situation_surface?
        evaluation_local_professionnel_with_any_anomaly_but_address?
      end

      # @attribute situation_coefficient_localisation
      #
      # This attribute is only displayed for:
      # * every `evaluation_local_pro` form with any anomalies but address
      #
      # This attribute is always required except for:
      # * an "industrial" nature is selected
      #
      def display_situation_coefficient_localisation?
        evaluation_local_professionnel_with_any_anomaly_but_address?
      end

      def require_situation_coefficient_localisation?
        display_situation_coefficient_localisation? && !situation_nature_industriel?
      end

      # @attribute situation_coefficient_entretien
      #
      # This attribute is only displayed and required for:
      # *  a `evaluation_local_hab` form with any anomalies but address
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
      # All attributes `situation_coefficient_situation_*` are displayed for:
      # *  a `evaluation_local_hab` form with any anomalies but address
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
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form, with any anomalies but adresse
      #
      def display_proposition_evaluation?
        evaluation_local_with_any_anomaly_but_address?
      end

      # This fieldset is considered as an habitation of a professional local
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
      # This attribute is only displayed and required for:
      # * every `evaluation_local_*` form with an `affectation` anomaly
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
      # This attribute is only displayed and required for:
      # * a `creation_local_*`
      # * a `affectation` anomaly on a `evaluation_local_*` form
      # * a `consistance` or `categorie` anomaly on a `evaluation_local_habitation` form
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
      # * a `creation_local_*`
      # * every `evaluation_local_*` form with of the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute always required except for:
      # * a `creation_local_*` with 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `affectation` and 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `consistance` or `categorie` and 'industrial' nature selected in situation
      #
      def display_proposition_categorie?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_categorie?
        display_proposition_categorie? &&
          !(creation_local? && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.include?("affectation") && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.intersect?(%w[consistance categorie]) && situation_nature_industriel?)
      end

      # @attribute proposition_surface_reelle
      #
      # This attribute is only displayed for:
      # * a `creation_local_*`
      # * every `evaluation_local_*` form with of the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute always required except for:
      # * a `creation_local_*` with 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `affectation` and 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `consistance` or `categorie` and 'industrial' nature selected in situation
      #
      def display_proposition_surface_reelle?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_surface_reelle?
        display_proposition_surface_reelle? &&
          !(creation_local? && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.include?("affectation") && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.intersect?(%w[consistance categorie]) && situation_nature_industriel?)
      end

      # @attribute proposition_surface_p1
      # @attribute proposition_surface_p2
      # @attribute proposition_surface_p3
      # @attribute proposition_surface_pk1
      # @attribute proposition_surface_pk2
      # @attribute proposition_surface_ponderee
      #
      # These attributes are displayed for:
      # * any proposition of a professional evaluation
      #
      # They are never required.
      #
      def display_other_proposition_surface?
        require_proposition_evaluation_professionnel?
      end

      # @attribute proposition_coefficient_localisation
      #
      # This attribute is only displayed for:
      # * any proposition of a professional evaluation
      #
      # This attribute always required except for:
      # * a `creation_local_*` with 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `affectation` and 'industrial' nature selected in proposition
      # * a `evaluation_local_*` form with of the anomalies `consistance` or `categorie` and 'industrial' nature selected in situation
      #
      def display_proposition_coefficient_localisation?
        require_proposition_evaluation_professionnel?
      end

      def require_proposition_coefficient_localisation?
        display_proposition_coefficient_localisation? &&
          !(creation_local? && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.include?("affectation") && proposition_nature_industriel?) &&
          !(evaluation_local? && anomalies.intersect?(%w[consistance categorie]) && situation_nature_industriel?)
      end

      # @attribute proposition_coefficient_entretien
      #
      # This attribute is only displayed and required for:
      # * any proposition of a habitation evaluation form
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
      # * any proposition of a habitation evaluation form
      #
      # They are never required.
      #
      def display_proposition_coefficient_situation?
        require_proposition_evaluation_habitation?
      end

      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form with of the anomalies `exoneration`
      #
      def display_proposition_exoneration?
        evaluation_local? && anomalies.include?("exoneration")
      end

      def require_proposition_exoneration?
        display_proposition_exoneration?
      end

      # @attribute proposition_libelle_voie
      #
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form with of the anomalies `adresse`
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
      # * every `creation_local_*` form
      #
      def display_proposition_creation_local?
        creation_local?
      end

      # @attribute proposition_nature_dependance
      #
      # This attribute is displayed and required for:
      # * a 'creation_local_habitation' form with a 'dependency' nature
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
      # * a 'creation_local_*' form
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
      # * a 'creation_local_*' form with a `construction_neuve` anomaly
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
      # * a 'creation_local_*' form with a `construction_neuve` anomaly
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
      # * every `occupation_local_*` form
      #
      def display_situation_occupation?
        occupation_local?
      end

      def require_situation_occupation_habitation?
        occupation_local_habitation?
      end

      def require_situation_occupation_professionnel?
        occupation_local_professionnel?
      end

      # @attribute situation_nature_occupation
      #
      # This attribute is displayed and required for:
      # * every `occupation_local_habitation` form
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
      # * every `occupation_local_habitation` form with `résidence secondaire` as situation_nature_occupation
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form where situation_vacance_fiscale is true
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_*` form
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
      # * every `occupation_local_habitation` form
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
      # * every `occupation_local_habitation` form
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
      # * every `occupation_local_habitation` form
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
      # * every `occupation_local_habitation` form with `vacant tlv` as situation_nature_occupation
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
      # * every `occupation_local_habitation` form with `vacant thlv` as situation_nature_occupation
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
      # * every `occupation_local_habitation` form without any `vacant` values as proposition_nature_occupation
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
      # * every `occupation_local_habitation` form with `résidence secondaire` as proposition_nature_occupation
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
      # * every `occupation_local_habitation` form without any `vacant` values as proposition_nature_occupation
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
      # * every `occupation_local_habitation` form without any `vacant` values as proposition_nature_occupation
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
      # * every `occupation_local_habitation` form without any `vacant` values as proposition_nature_occupation
      #
      # It is never required.
      #
      def display_proposition_adresse_occupant?
        occupation_local_habitation? && %w[RP RS RE].include?(@report.proposition_nature_occupation)
      end

      # @attribute proposition_numero_siren
      #
      # This attribute is displayed and required for:
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
      #
      # It is never required.
      #
      def display_proposition_nom_enseigne?
        occupation_local_professionnel?
      end

      # @attribute proposition_etablissement_principal
      #
      # This attribute is displayed and required for:
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
      # * every `occupation_local_professionnel` form
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
        anomalies.intersect?(%w[affectation consistance correctif exoneration])
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

    def creation_local?
      @creation_local ||= form_type.start_with?("creation_local_")
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

    def situation_nature_industriel?
      @report.situation_nature == "U"
    end

    def proposition_nature_industriel?
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
