# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class SituationOccupation < self
          def situation_nature_occupation_choices
            enum_options(:local_habitation_occupation)
          end

          def boolean_choices
            enum_options(:boolean)
          end

          def residence_secondaire_fields(&)
            hidden = disabled = (@report.situation_nature_occupation != "RS")
            data = {
              switch_target: "show",
              switch_value:  "RS"
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def vacance_fiscale_fields(&)
            hidden = disabled = !@report.situation_vacance_fiscale
            data = {
              switch_target: "show",
              switch_value:  "true"
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end
        end
      end
    end
  end
end
