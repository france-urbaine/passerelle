# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class SituationOccupation < self
          def situation_nature_occupation
            translate_enum(@report.situation_nature_occupation, scope: "enum.local_habitation_occupation")
          end
        end
      end
    end
  end
end
