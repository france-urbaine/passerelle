# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class SituationEvaluation < self
        def before_render
          @report.situation_date_mutation = nil if @report.situation_date_mutation.blank?
        end

        def affectation_choices
          if require_situation_evaluation_habitation? || require_situation_occupation?
            enum_options(:local_habitation_affectation)
          elsif require_situation_evaluation_professionnel?
            enum_options(:local_professionnel_affectation)
          else
            []
          end
        end

        def nature_choices
          if require_situation_evaluation_habitation? || require_situation_occupation?
            enum_options(:local_habitation_nature)
          elsif require_situation_evaluation_professionnel?
            enum_options(:local_professionnel_nature)
          else
            []
          end
        end

        def categorie_choices
          if require_situation_evaluation_habitation? || require_situation_occupation?
            enum_options(:local_habitation_categorie)
          elsif require_situation_evaluation_professionnel?
            enum_options(:local_professionnel_categorie)
          else
            []
          end
        end

        def coefficient_entretien_choices
          enum_options(:coefficient_entretien)
        end

        def coefficient_situation_choices
          enum_options(:coefficient_situation)
        end

        def situation_date_mutation
          parse_date(@report.situation_date_mutation) || @report.situation_date_mutation
        end
      end
    end
  end
end
