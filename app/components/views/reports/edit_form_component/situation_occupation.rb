# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class SituationOccupation < self
        def situation_occupation
          enum_options(:occupation_local_habitation)
        end
      end
    end
  end
end
