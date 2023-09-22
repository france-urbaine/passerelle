# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class PropositionOccupation < self
        def proposition_nature_occupation
          t(@report.proposition_nature_occupation, scope: "enum.local_habitation_occupation")
        end
      end
    end
  end
end
