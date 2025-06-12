# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class SituationEvaluation < self
          def situation_affectation
            translate_enum(@report.situation_affectation, scope: "enum.local_affectation")
          end

          def situation_nature
            translate_enum(@report.situation_nature, scope: "enum.local_nature")
          end

          def situation_categorie
            if expect_situation_categorie_habitation?
              translate_enum(@report.situation_categorie, scope: "enum.local_habitation_categorie")
            elsif expect_situation_categorie_dependance?
              translate_enum(@report.situation_categorie, scope: "enum.local_dependance_categorie")
            elsif expect_situation_categorie_professionnel?
              translate_enum(@report.situation_categorie, scope: "enum.local_professionnel_categorie")
            end
          end

          def situation_coefficient_entretien
            translate_enum(@report.situation_coefficient_entretien, scope: "enum.coefficient_entretien")
          end

          def situation_coefficient_situation_generale
            translate_enum(@report.situation_coefficient_situation_generale, scope: "enum.coefficient_situation")
          end

          def situation_coefficient_situation_particuliere
            translate_enum(@report.situation_coefficient_situation_particuliere, scope: "enum.coefficient_situation")
          end
        end
      end
    end
  end
end
