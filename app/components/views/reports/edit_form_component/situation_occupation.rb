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
      end
    end
  end
end
