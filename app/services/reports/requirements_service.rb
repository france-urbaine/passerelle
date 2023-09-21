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
      method.match?(/^(require|display)_.*\?$/) && respond_to?(method)
    end

    # Requirements for basic situation informations
    # --------------------------------------------------------------------------
    concerning :SituationMajic do
      def require_situation_majic?
        evaluation_local? || occupation_local?
      end

      def require_situation_parcelle?
        evaluation_local? || creation_local?
      end

      def require_situation_adresse?
        evaluation_local? || creation_local? || occupation_local?
      end

      def require_situation_porte?
        evaluation_local? || occupation_local?
      end

      def require_situation_proprietaire?
        evaluation_local? || creation_local?
      end
    end

    # Requirements for current evaluation
    # --------------------------------------------------------------------------
    concerning :SituationEvaluation do
      # This fieldset is displayed and required for:
      # * every `evaluation_local_*` form with any anomalies but address
      # * every `occupation_local_*` form
      #
      def display_situation_evaluation?
        evaluation_local_with_any_anomaly_but_address? || occupation_local?
      end

      def require_situation_evaluation?
        display_situation_evaluation?
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
      def require_proposition_evaluation?
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
      # This attribute is only displayed for:
      # * a `creation_local_*`
      # * every `evaluation_local_*` form with of the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute is always required except for:
      # * an "industrial" nature is selected
      #
      def display_proposition_categorie?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_categorie?
        display_proposition_categorie? && !proposition_nature_industriel?
      end

      # @attribute proposition_surface_reelle
      #
      # This attribute is only displayed for:
      # * a `creation_local_*`
      # * every `evaluation_local_*` form with of the anomalies `affectation`, `consistance` or `categorie`
      #
      # This attribute is always required except for:
      # * an "industrial" nature is selected
      #
      def display_proposition_surface_reelle?
        creation_local? || (
          evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie])
        )
      end

      def require_proposition_surface_reelle?
        display_proposition_surface_reelle? && !proposition_nature_industriel?
      end

      # @attribute proposition_surface_p1
      # @attribute proposition_surface_p2
      # @attribute proposition_surface_p3
      # @attribute proposition_surface_pk1
      # @attribute proposition_surface_pk2
      # @attribute proposition_surface_ponderee
      #
      # Other `proposition_surface_*` attributes are displayed for:
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
      # This attribute is always required except for:
      # * an "industrial" nature is selected
      #
      def display_proposition_coefficient_localisation?
        require_proposition_evaluation_professionnel?
      end

      def require_proposition_coefficient_localisation?
        display_proposition_coefficient_localisation? && !proposition_nature_industriel?
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
      # All attributes `proposition_coefficient_situation_*` are displayed for:
      # * any proposition of a habitation evaluation form
      #
      # They are never required.
      #
      def display_proposition_coefficient_situation?
        require_proposition_evaluation_habitation?
      end


      ####

      def require_proposition_adresse?
        evaluation_local? && anomalies.include?("adresse")
      end

      def require_proposition_exoneration?
        evaluation_local? && anomalies.include?("exoneration")
      end
    end

    # Requirements for new buildings
    # --------------------------------------------------------------------------
    def require_proposition_omission_batie?
      creation_local? && anomalies.include?("omission_batie")
    end

    def require_proposition_construction_neuve?
      creation_local? && anomalies.include?("construction_neuve")
    end

    def require_proposition_nature_dependance?
      form_type == "creation_local_habitation" &&
        %w[DA DM].include?(@report.proposition_nature)
    end

    def require_proposition_date_achevement?
      creation_local?
    end

    def require_proposition_occupation?
      occupation_local_habitation?
    end

    # Requirements for occupations
    # --------------------------------------------------------------------------
    def require_occupation?
      occupation_local_habitation? || occupation_local_professionnel?
    end

    def require_occupation_habitation?
      occupation_local_habitation?
    end

    def require_occupation_professionnel?
      occupation_local_professionnel?
    end

    def require_situation_occupation_residence_secondaire?
      situation_occupation_residence_secondaire?
    end

    def require_proposition_occupation_residence_secondaire?
      proposition_occupation_residence_secondaire?
    end

    def require_proposition_occupation_local_non_vacant?
      proposition_occupation_local_non_vacant?
    end

    def require_proposition_erreur_tlv?
      situation_occupation_vacant_tlv?
    end

    def require_proposition_erreur_thlv?
      situation_occupation_vacant_thlv?
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

    def occupation_local?
      @occupation_local ||= form_type.start_with?("occupation_local_")
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

    def occupation_local_habitation?
      @occupation_local_habitation ||= form_type == "occupation_local_habitation"
    end

    def occupation_local_professionnel?
      @occupation_local_professionnel ||= form_type == "occupation_local_professionnel"
    end

    def situation_occupation_residence_secondaire?
      @report.situation_occupation == "RS"
    end

    def situation_occupation_vacant_tlv?
      @report.situation_occupation == "vacant_tlv"
    end

    def situation_occupation_vacant_thlv?
      @report.situation_occupation == "vacant_thlv"
    end

    def proposition_occupation_residence_secondaire?
      @report.proposition_occupation == "RS"
    end

    def proposition_occupation_local_non_vacant?
      %w[RP RS RE].include?(@report.proposition_occupation)
    end
  end
end
