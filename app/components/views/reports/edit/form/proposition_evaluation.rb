# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Form
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
              I18n.t("enum.local_professionnel_affectation").map(&:reverse)
            else
              I18n.t("enum.local_affectation").map(&:reverse)
            end
          end

          def nature_habitation_choices
            I18n.t("enum.local_habitation_nature").map(&:reverse)
          end

          def nature_professionnel_choices
            I18n.t("enum.local_professionnel_nature").map(&:reverse)
          end

          def categorie_habitation_choices
            I18n.t("enum.local_habitation_categorie").map(&:reverse)
          end

          def categorie_professionnel_choices
            I18n.t("enum.local_professionnel_categorie").map(&:reverse)
          end

          def coefficient_entretien_choices
            I18n.t("enum.coefficient_entretien").map(&:reverse)
          end

          def coefficient_situation_choices
            I18n.t("enum.coefficient_situation").map(&:reverse)
          end
        end
      end
    end
  end
end
