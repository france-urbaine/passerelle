# frozen_string_literal: true

module Reports
  class RequirementsService
    include ::ActiveModel::Model

    attr_reader :report

    delegate :form_type, :anomalies, to: :report

    def initialize(report)
      @report = report
      super()
    end

    def require_situation_majic?
      form_type.match?(/^evaluation_local_/)
    end

    def require_situation_evaluation?
      require_situation_evaluation_habitation? || require_situation_evaluation_professionnel?
    end

    def require_situation_evaluation_habitation?
      form_type == "evaluation_local_habitation" && anomalies.intersect?(%w[affectation consistance])
    end

    def require_situation_evaluation_professionnel?
      form_type == "evaluation_local_professionnel" && anomalies.intersect?(%w[affectation consistance])
    end

    def require_proposition_affectation?
      form_type.match?(/^evaluation_local_/) && anomalies.include?("affectation")
    end

    def require_proposition_adresse?
      form_type.match?(/^evaluation_local_/) && anomalies.include?("adresse")
    end

    def require_proposition_evaluation?
      require_proposition_evaluation_habitation? || require_proposition_evaluation_professionnel?
    end

    def require_proposition_evaluation_habitation?
      case form_type
      when "evaluation_local_habitation"
        (anomalies.include?("affectation") && proposition_affectation_habitation?) ||
          (anomalies.exclude?("affectation") && anomalies.include?("consistance"))
      when "evaluation_local_professionnel"
        anomalies.include?("affectation") && proposition_affectation_habitation?
      end
    end

    def require_proposition_evaluation_professionnel?
      case form_type
      when "evaluation_local_professionnel"
        (anomalies.include?("affectation") && proposition_affectation_professionnel?) ||
          (anomalies.exclude?("affectation") && anomalies.include?("consistance"))
      when "evaluation_local_habitation"
        anomalies.include?("affectation") && proposition_affectation_professionnel?
      end
    end

    def proposition_affectation_habitation?
      I18n.t("enum.affectation_local_habitation").keys.map(&:to_s).include?(@report.proposition_affectation)
    end

    def proposition_affectation_professionnel?
      I18n.t("enum.affectation_local_professionnel").keys.map(&:to_s).include?(@report.proposition_affectation)
    end
  end
end
