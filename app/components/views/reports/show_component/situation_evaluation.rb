# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class SituationEvaluation < self
        def situation_affectation
          t(@report.situation_affectation, scope: "enum.local_affectation")
        end

        def situation_nature
          t(@report.situation_nature, scope: "enum.local_nature")
        end

        def situation_categorie
          if require_situation_evaluation_habitation? || require_occupation_habitation?
            t(@report.situation_categorie, scope: "enum.local_habitation_categorie")
          elsif require_situation_evaluation_professionnel? || require_occupation_professionnel?
            t(@report.situation_categorie, scope: "enum.local_professionnel_categorie")
          end
        end

        def situation_coefficient_entretien
          t(@report.situation_coefficient_entretien, scope: "enum.coefficient_entretien")
        end

        def situation_coefficient_situation_generale
          t(@report.situation_coefficient_situation_generale, scope: "enum.coefficient_situation")
        end

        def situation_coefficient_situation_particuliere
          t(@report.situation_coefficient_situation_particuliere, scope: "enum.coefficient_situation")
        end
      end
    end
  end
end
