# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class SituationEvaluation < self
          def situation_affectation
            t(@report.situation_affectation, scope: "enum.local_affectation")
          end

          def situation_nature
            t(@report.situation_nature, scope: "enum.local_nature")
          end

          def situation_categorie
            if require_situation_evaluation_habitation?
              I18n.t(@report.situation_categorie, scope: "enum.local_habitation_categorie")
            elsif require_situation_evaluation_professionnel?
              I18n.t(@report.situation_categorie, scope: "enum.local_professionnel_categorie")
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

          def t(value, **options)
            I18n.t(value, **options) if value.present?
          end
        end
      end
    end
  end
end
