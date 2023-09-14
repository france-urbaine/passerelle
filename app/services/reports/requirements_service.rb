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
      method.match?(/^require_.*\?$/) && respond_to?(method)
    end

    # Requirements for basic situation informations
    # --------------------------------------------------------------------------
    def require_situation_majic?
      evaluation_local? || require_occupation?
    end

    def require_situation_parcelle?
      evaluation_local? || creation_local?
    end

    def require_situation_adresse?
      evaluation_local? || creation_local?
    end

    def require_situation_porte?
      evaluation_local?
    end

    def require_situation_proprietaire?
      evaluation_local? || creation_local?
    end

    # Requirements for current evaluation
    # --------------------------------------------------------------------------
    def require_situation_evaluation?
      (evaluation_local? && anomalies.intersect?(%w[affectation consistance categorie correctif exoneration])) ||
        require_occupation?
    end

    def require_situation_evaluation_habitation?
      @require_situation_evaluation_habitation ||=
        form_type == "evaluation_local_habitation" &&
        anomalies.intersect?(%w[affectation consistance correctif exoneration])
    end

    def require_situation_evaluation_professionnel?
      @require_situation_evaluation_professionnel ||=
        form_type == "evaluation_local_professionnel" &&
        anomalies.intersect?(%w[affectation consistance categorie exoneration])
    end

    def require_situation_categorie?
      require_situation_evaluation? && !situation_nature_industriel?
    end

    def require_situation_surface?
      require_situation_evaluation? && !situation_nature_industriel?
    end

    def require_situation_coefficient_localisation?
      require_situation_evaluation_professionnel? && !situation_nature_industriel?
    end

    # Requirements for new evaluation
    # --------------------------------------------------------------------------
    def require_proposition_evaluation?
      @require_proposition_evaluation ||=
        evaluation_local? &&
        anomalies.intersect?(%w[affectation consistance categorie correctif])
    end

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

    def require_proposition_affectation?
      evaluation_local? &&
        anomalies.include?("affectation")
    end

    def require_proposition_nature?
      require_proposition_affectation? || creation_local? ||
        (
          form_type == "evaluation_local_habitation" &&
            anomalies.intersect?(%w[consistance categorie])
        )
    end

    def require_proposition_consistance?
      evaluation_local? &&
        anomalies.intersect?(%w[affectation consistance categorie])
    end

    def require_proposition_categorie?
      (require_proposition_consistance? || creation_local?) &&
        !proposition_nature_industriel?
    end

    def require_proposition_surface?
      (require_proposition_consistance? || creation_local?) &&
        !proposition_nature_industriel?
    end

    def require_proposition_correctif?
      require_proposition_evaluation_habitation? &&
        anomalies.intersect?(%w[affectation consistance categorie correctif])
    end

    def require_proposition_coefficient_localisation?
      require_proposition_evaluation_professionnel? &&
        require_proposition_consistance? &&
        !proposition_nature_industriel?
    end

    def require_proposition_adresse?
      evaluation_local? && anomalies.include?("adresse")
    end

    def require_proposition_exoneration?
      evaluation_local? && anomalies.include?("exoneration")
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

    # --------------------------------------------------------------------------
    private

    delegate :form_type, :anomalies, to: :report

    def evaluation_local?
      @evaluation_local ||= form_type.start_with?("evaluation_local_")
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

    def occupation_local_habitation?
      @occupation_local_habitation ||= form_type == "occupation_local_habitation"
    end

    def occupation_local_professionnel?
      @occupation_local_professionnel ||= form_type == "occupation_local_professionnel"
    end
  end
end
