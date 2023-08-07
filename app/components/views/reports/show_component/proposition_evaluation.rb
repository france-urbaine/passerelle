# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class PropositionEvaluation < self
        def proposition_affectation
          t(@report.proposition_affectation, scope: "enum.local_affectation")
        end

        def proposition_nature
          if require_proposition_evaluation_habitation?
            t(@report.proposition_nature, scope: "enum.local_habitation_nature", default: "")
          elsif require_proposition_evaluation_professionnel?
            t(@report.proposition_nature, scope: "enum.local_professionnel_nature", default: "")
          end
        end

        def proposition_categorie
          if require_proposition_evaluation_habitation?
            t(@report.proposition_categorie, scope: "enum.local_habitation_categorie", default: "")
          elsif require_proposition_evaluation_professionnel?
            t(@report.proposition_categorie, scope: "enum.local_professionnel_categorie", default: "")
          end
        end

        def proposition_coefficient_entretien
          t(@report.proposition_coefficient_entretien, scope: "enum.coefficient_entretien")
        end

        def proposition_coefficient_situation_generale
          t(@report.proposition_coefficient_situation_generale, scope: "enum.coefficient_situation")
        end

        def proposition_coefficient_situation_particuliere
          t(@report.proposition_coefficient_situation_particuliere, scope: "enum.coefficient_situation")
        end

        def t(value, **options)
          I18n.t(value, **options) if value.present?
        end
      end
    end
  end
end
