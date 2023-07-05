# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Form
        class PropositionEvaluation < self
          def controller_html_attributes
            {
              data: {
                controller: "report-form",
                report_form_affectation_habitation_value: I18n.t("enum.local_habitation_affectation").keys,
                report_form_affectation_professionnel_value: I18n.t("enum.local_professionnel_affectation").keys
              }
            }
          end

          def affectation_input_html_attributes
            { data: { action: "change->report-form#toggleAffectation", report_form_target: "affectationInput" } }
          end

          def habitation_html_attributes
            {
              data: { report_form_target: "habitation" },
              hidden: !require_proposition_evaluation_habitation?
            }
          end

          def professionnel_html_attributes
            {
              data: { report_form_target: "professionnel" },
              hidden: !require_proposition_evaluation_professionnel?
            }
          end

          def habitation_input_html_attributes
            {
              data: { report_form_target: "habitationInput" },
              disabled: !require_proposition_evaluation_habitation?
            }
          end

          def professionnel_input_html_attributes
            {
              data: { report_form_target: "professionnelInput" },
              disabled: !require_proposition_evaluation_professionnel?
            }
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
