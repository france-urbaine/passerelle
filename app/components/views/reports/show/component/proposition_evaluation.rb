# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class PropositionEvaluation < self
          def proposition_affectation
            t(@report.proposition_affectation, scope: "enum.affectation")
          end

          def proposition_nature
            if require_proposition_evaluation_habitation?
              t(@report.proposition_nature, scope: "enum.nature_local_habitation", default: "")
            elsif require_proposition_evaluation_professionnel?
              t(@report.proposition_nature, scope: "enum.nature_local_professionnel", default: "")
            end
          end

          def proposition_categorie
            if require_proposition_evaluation_habitation?
              t(@report.proposition_categorie, scope: "enum.categorie_habitation", default: "")
            elsif require_proposition_evaluation_professionnel?
              t(@report.proposition_categorie, scope: "enum.categorie_economique", default: "")
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
end
