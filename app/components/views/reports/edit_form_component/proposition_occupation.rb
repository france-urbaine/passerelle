# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class PropositionOccupation < self
        def proposition_occupation
          enum_options(:local_habitation_occupation)
        end

        def situation_occupation_vacant_tlv?
          @report.situation_occupation == "vacant_tlv"
        end

        def situation_occupation_vacant_thlv?
          @report.situation_occupation == "vacant_thlv"
        end
      end
    end
  end
end
