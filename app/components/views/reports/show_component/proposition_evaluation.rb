# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class PropositionEvaluation < self
        def proposition_affectation
          translate_enum(@report.proposition_affectation, scope: "enum.local_affectation")
        end

        def proposition_nature
          if require_proposition_evaluation_habitation?
            translate_enum(@report.proposition_nature, scope: "enum.local_habitation_nature")
          elsif require_proposition_evaluation_professionnel?
            translate_enum(@report.proposition_nature, scope: "enum.local_professionnel_nature")
          end
        end

        def proposition_categorie
          if require_proposition_evaluation_habitation?
            translate_enum(@report.proposition_categorie, scope: "enum.local_habitation_categorie")
          elsif require_proposition_evaluation_professionnel?
            translate_enum(@report.proposition_categorie, scope: "enum.local_professionnel_categorie")
          end
        end

        def proposition_coefficient_entretien
          translate_enum(@report.proposition_coefficient_entretien, scope: "enum.coefficient_entretien")
        end

        def proposition_coefficient_situation_generale
          translate_enum(@report.proposition_coefficient_situation_generale, scope: "enum.coefficient_situation")
        end

        def proposition_coefficient_situation_particuliere
          translate_enum(@report.proposition_coefficient_situation_particuliere, scope: "enum.coefficient_situation")
        end
      end
    end
  end
end
