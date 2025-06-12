# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class SituationEvaluation < self
          def before_render
            @report.situation_date_mutation = nil if @report.situation_date_mutation.blank?
          end

          def nature_habitation_fields(&)
            values = nature_habitation_values
            active = @report.situation_nature.nil? || values.include?(@report.situation_nature)
            hidden = disabled = !active

            data = {
              switch_target:          "target",
              switch_value:           values.join(","),
              switch_value_separator: ","
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_professionnel_fields(&)
            values = nature_professionnel_values
            hidden = disabled = values.exclude?(@report.situation_nature)

            data = {
              switch_target:          "target",
              switch_value:           values.join(","),
              switch_value_separator: ","
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_dependance_fields(&)
            values = nature_dependance_values
            hidden = disabled = values.exclude?(@report.situation_nature)

            data = {
              switch_target:          "target",
              switch_value:           values.join(","),
              switch_value_separator: ","
            }
            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def nature_habitation_values
            if require_situation_evaluation_habitation?
              I18n.t("enum.local_habitation_nature").keys.map(&:to_s) - nature_dependance_values
            else
              []
            end
          end

          def nature_professionnel_values
            if require_situation_evaluation_professionnel?
              I18n.t("enum.local_professionnel_nature").keys.map(&:to_s)
            else
              []
            end
          end

          def nature_dependance_values
            if require_situation_evaluation_habitation?
              %w[DA DM DE LC]
            else
              []
            end
          end

          def affectation_choices
            if require_situation_evaluation_habitation?
              enum_options(:local_habitation_affectation)
            elsif require_situation_evaluation_professionnel?
              enum_options(:local_professionnel_affectation)
            else
              []
            end
          end

          def nature_choices
            if require_situation_evaluation_habitation?
              enum_options(:local_habitation_nature)
            elsif require_situation_evaluation_professionnel?
              enum_options(:local_professionnel_nature)
            else
              []
            end
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

          def situation_date_mutation
            parse_date(@report.situation_date_mutation) || @report.situation_date_mutation
          end
        end
      end
    end
  end
end
