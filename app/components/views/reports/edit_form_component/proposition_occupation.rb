# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class PropositionOccupation < self
        def proposition_occupation
          enum_options(:local_habitation_occupation)
        end

        def boolean_options
          enum_options(:boolean)
        end

        def residence_secondaire_fields(&)
          data = {
            switch_target: "target",
            switch_value:  "RS"
          }

          tag.div(data:, hidden: !require_proposition_occupation_residence_secondaire?, &)
        end

        def local_non_vacant_fields(&)
          data = {
            switch_target:          "target",
            switch_value:           %w[RP RS RE].join(","),
            switch_value_separator: ","
          }

          tag.div(data:, hidden: !require_proposition_occupation_local_non_vacant?, &)
        end
      end
    end
  end
end
