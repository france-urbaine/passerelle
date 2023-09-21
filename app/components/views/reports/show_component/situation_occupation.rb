# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class SituationOccupation < self
        def situation_occupation
          t(@report.situation_occupation, scope: "enum.local_habitation_occupation")
        end

        def situation_occupation_rs?
          @report.situation_occupation == "RS"
        end
      end
    end
  end
end
