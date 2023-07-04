# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields
        class PropositionEvaluation < self
          def controller_html_options
            {
              data: {
                controller: "report-form",
                report_form_affectation_habitation_value: I18n.t("enum.affectation_local_habitation").keys,
                report_form_affectation_professionnel_value: I18n.t("enum.affectation_local_professionnel").keys
              }
            }
          end

          def affectation_input_html_options
            { data: { action: "change->report-form#toggleAffectation", report_form_target: "affectationInput" } }
          end

          def habitation_html_options
            {
              data: { report_form_target: "habitation" },
              hidden: !require_proposition_evaluation_habitation?
            }
          end

          def professionnel_html_options
            {
              data: { report_form_target: "professionnel" },
              hidden: !require_proposition_evaluation_professionnel?
            }
          end

          def habitation_input_html_options
            {
              data: { report_form_target: "habitationInput" },
              disabled: !require_proposition_evaluation_habitation?
            }
          end

          def professionnel_input_html_options
            {
              data: { report_form_target: "professionnelInput" },
              disabled: !require_proposition_evaluation_professionnel?
            }
          end

          def affectation_options
            case @report.form_type
            when "evaluation_local_habitation"
              I18n.t("enum.affectation_local_professionnel").map(&:reverse)
            else
              I18n.t("enum.affectation").map(&:reverse)
            end
          end

          def nature_habitation_options
            I18n.t("enum.nature_local_habitation").map(&:reverse)
          end

          def nature_professionnel_options
            I18n.t("enum.nature_local_professionnel").map(&:reverse)
          end

          def categorie_habitation_options
            I18n.t("enum.categorie_habitation").map(&:reverse)
          end

          def categorie_professionnel_options
            I18n.t("enum.categorie_economique").map(&:reverse)
          end

          def coefficient_entretien_options
            I18n.t("enum.coefficient_entretien").map(&:reverse)
          end

          def coefficient_situation_options
            I18n.t("enum.coefficient_situation").map(&:reverse)
          end
        end
      end
    end
  end
end
