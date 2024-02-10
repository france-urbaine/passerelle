# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class PropositionOccupation < self
          def proposition_nature_occupation
            translate_enum(@report.proposition_nature_occupation, scope: "enum.local_habitation_occupation")
          end
        end
      end
    end
  end
end
