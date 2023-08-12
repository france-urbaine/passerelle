# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class PropositionEvaluation < self
        SWITCH_SEPARATOR = ","

        def habitation_fields(&)
          data = {
            switch_target:          "target",
            switch_value:           I18n.t("enum.local_habitation_affectation").keys.join(SWITCH_SEPARATOR),
            switch_value_separator: SWITCH_SEPARATOR
          }

          tag.div(data:, hidden: !require_proposition_evaluation_habitation?, &)
        end

        def professionnel_fields(&)
          data = {
            switch_target:          "target",
            switch_value:           I18n.t("enum.local_professionnel_affectation").keys.join(SWITCH_SEPARATOR),
            switch_value_separator: SWITCH_SEPARATOR
          }

          tag.div(data:, hidden: !require_proposition_evaluation_professionnel?, &)
        end

        def affectation_choices
          case @report.form_type
          when "evaluation_local_habitation"
            enum_options(:local_professionnel_affectation)
          else
            enum_options(:local_affectation)
          end
        end

        def nature_choices
          if require_proposition_evaluation_habitation?
            nature_habitation_choices
          else
            nature_professionnel_choices
          end
        end

        def nature_habitation_choices
          enum_options(:local_habitation_nature)
        end

        def nature_professionnel_choices
          enum_options(:local_professionnel_nature)
        end

        def categorie_choices
          if require_proposition_evaluation_habitation?
            categorie_habitation_choices
          else
            categorie_professionnel_choices
          end
        end

        def categorie_habitation_choices
          enum_options(:local_habitation_categorie)
        end

        def categorie_professionnel_choices
          enum_options(:local_professionnel_categorie)
        end

        def coefficient_entretien_choices
          enum_options(:coefficient_entretien)
        end

        def coefficient_situation_choices
          enum_options(:coefficient_situation)
        end
      end
    end
  end
end
