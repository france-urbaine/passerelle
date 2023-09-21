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

        def situation_occupation_vacant_tlv?
          @report.situation_occupation == "vacant_tlv"
        end

        def situation_occupation_vacant_thlv?
          @report.situation_occupation == "vacant_thlv"
        end

        def residence_secondaire_fields(&)
          data = {
            switch_target: "target",
            switch_value:  "RS"
          }

          tag.div(data:, hidden: @report.proposition_occupation != "RS", &)
        end

        def local_non_vacant_fields(&)
          relevant_values = %w[RP RS RE]
          data = {
            switch_target:          "target",
            switch_value:           relevant_values.join(","),
            switch_value_separator: ","
          }

          tag.div(data:, hidden: relevant_values.exclude?(@report.proposition_occupation), &)
        end
      end
    end
  end
end
