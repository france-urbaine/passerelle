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

    def require_situation_majic?
      form_type.start_with?("evaluation_local_")
    end

    # Required situation evaluation
    # --------------------------------------------------------------------------
    def require_situation_evaluation?
      form_type.start_with?("evaluation_local_") &&
        anomalies.intersect?(%w[affectation consistance categorie correctif exoneration])
    end

    def require_situation_evaluation_habitation?
      form_type == "evaluation_local_habitation" &&
        anomalies.intersect?(%w[affectation consistance correctif exoneration])
    end

    def require_situation_evaluation_professionnel?
      form_type == "evaluation_local_professionnel" &&
        anomalies.intersect?(%w[affectation consistance categorie exoneration])
    end

    def require_situation_categorie?
      require_situation_evaluation? &&
        !situation_nature_industriel?
    end

    def require_situation_surface?
      require_situation_evaluation? &&
        !situation_nature_industriel?
    end

    def require_situation_coefficient_localisation?
      require_situation_evaluation_professionnel? &&
        !situation_nature_industriel?
    end

    # Required proposition evaluation
    # --------------------------------------------------------------------------
    def require_proposition_evaluation?
      form_type.start_with?("evaluation_local_") &&
        anomalies.intersect?(%w[affectation consistance categorie correctif])
    end

    def require_proposition_evaluation_habitation?
      case form_type
      when "evaluation_local_habitation"
        (anomalies.include?("affectation") && proposition_affectation_habitation?) ||
          (anomalies.exclude?("affectation") && anomalies.intersect?(%w[consistance correctif]))
      when "evaluation_local_professionnel"
        anomalies.include?("affectation") && proposition_affectation_habitation?
      end
    end

    def require_proposition_evaluation_professionnel?
      case form_type
      when "evaluation_local_professionnel"
        (anomalies.include?("affectation") && proposition_affectation_professionnel?) ||
          (anomalies.exclude?("affectation") && anomalies.intersect?(%w[consistance categorie]))
      when "evaluation_local_habitation"
        anomalies.include?("affectation") && proposition_affectation_professionnel?
      end
    end

    def require_proposition_affectation?
      form_type.start_with?("evaluation_local_") &&
        anomalies.include?("affectation")
    end

    def require_proposition_nature?
      require_proposition_affectation? || (
        form_type == "evaluation_local_habitation" &&
          anomalies.intersect?(%w[consistance categorie])
      )
    end

    def require_proposition_consistance?
      form_type.start_with?("evaluation_local_") &&
        anomalies.intersect?(%w[affectation consistance categorie])
    end

    def require_proposition_categorie?
      require_proposition_consistance? &&
        !proposition_nature_industriel?
    end

    def require_proposition_surface?
      require_proposition_consistance? &&
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
      form_type.start_with?("evaluation_local_") && anomalies.include?("adresse")
    end

    def require_proposition_exoneration?
      form_type.start_with?("evaluation_local_") && anomalies.include?("exoneration")
    end

    # --------------------------------------------------------------------------
    private

    delegate :form_type, :anomalies, to: :report

    def proposition_affectation_habitation?
      I18n.t("enum.local_habitation_affectation").keys.map(&:to_s).include?(@report.proposition_affectation)
    end

    def proposition_affectation_professionnel?
      I18n.t("enum.local_professionnel_affectation").keys.map(&:to_s).include?(@report.proposition_affectation)
    end

    def situation_nature_industriel?
      @report.situation_nature == "U"
    end

    def proposition_nature_industriel?
      @report.proposition_nature == "U"
    end
  end
end
