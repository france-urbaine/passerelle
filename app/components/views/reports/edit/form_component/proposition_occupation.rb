# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class PropositionOccupation < self
          def proposition_nature_occupation_choices
            enum_options(:local_habitation_occupation)
          end

          def boolean_choices
            enum_options(:boolean)
          end

          def residence_secondaire_fields(&)
            hidden = disabled = (@report.proposition_nature_occupation != "RS")
            data = {
              switch_target: "show",
              switch_value:  "RS"
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def local_non_vacant_fields(&)
            hidden = disabled = %w[RP RS RE].exclude?(@report.proposition_nature_occupation)
            data = {
              switch_target:          "show",
              switch_value:           %w[RP RS RE].join(","),
              switch_value_separator: ","
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end
        end
      end
    end
  end
end
