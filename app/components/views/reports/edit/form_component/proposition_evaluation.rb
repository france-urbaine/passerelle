# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class PropositionEvaluation < self
          SWITCH_SEPARATOR = ","

          def affectation_habitation_fields(&)
            hidden = disabled = !require_proposition_evaluation_habitation?

            data = {
              switch_form_target:        "show",
              switch_form_target_group:  "affectation",
              switch_form_target_values:  I18n.t("enum.local_habitation_affectation").keys
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def affectation_professionnel_fields(&)
            hidden = disabled = !require_proposition_evaluation_professionnel?

            data = {
              switch_form_target:        "show",
              switch_form_target_group:  "affectation",
              switch_form_target_values:  I18n.t("enum.local_professionnel_affectation").keys
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_habitation_fields(&)
            values = I18n.t("enum.local_habitation_nature").keys - %i[DA DM DE LC]
            active = @report.proposition_nature.nil? || values.include?(@report.proposition_nature.to_sym)
            hidden = disabled = !active

            data = {
              switch_form_target:        "show",
              switch_form_target_group:  "nature_habitation",
              switch_form_target_values:  values
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_dependance_fields(&)
            values = %w[DA DM DE LC]
            hidden = disabled = values.exclude?(@report.proposition_nature)

            data = {
              switch_form_target:        "show",
              switch_form_target_group:  "nature_habitation",
              switch_form_target_values:  values
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_professionnel_fields(&)
            values = I18n.t("enum.local_professionnel_nature").keys
            active = @report.proposition_nature.nil? || values.include?(@report.proposition_nature.to_sym)
            hidden = disabled = !active

            data = {
              switch_form_target:        "show",
              switch_form_target_group:  "nature_professionnel",
              switch_form_target_values:  values
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def affectation_choices
            case @report.form_type
            when "evaluation_local_habitation"
              enum_options(:local_professionnel_affectation)
            else
              enum_options(:local_affectation)
            end
          end

          def nature_habitation_choices
            enum_options(:local_habitation_nature)
          end

          def nature_professionnel_choices
            enum_options(:local_professionnel_nature)
          end

          def nature_dependance_choices
            enum_options(:local_nature_dependance)
          end

          def categorie_habitation_choices
            enum_options(:local_habitation_categorie)
          end

          def categorie_professionnel_choices
            enum_options(:local_professionnel_categorie)
          end

          def categorie_dependance_choices
            enum_options(:local_dependance_categorie)
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
end
