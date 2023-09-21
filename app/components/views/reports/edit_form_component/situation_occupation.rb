# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class SituationOccupation < self
        def situation_occupation
          enum_options(:local_habitation_occupation)
        end

        def boolean_options
          enum_options(:boolean)
        end

        def residence_secondaire_fields(&)
          data = {
            switch_target:          "target",
            switch_value:           "RS"
          }

          tag.div(data:, hidden: !require_situation_occupation_residence_secondaire?, &)
        end
      end
    end
  end
end
