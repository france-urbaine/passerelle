# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class SituationOccupation < self
        def situation_nature_occupation
          t(@report.situation_nature_occupation, scope: "enum.local_habitation_occupation")
        end
      end
    end
  end
end
