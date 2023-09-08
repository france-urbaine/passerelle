# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class PropositionOccupation < self
        def proposition_occupation
          t(@report.proposition_occupation, scope: "enum.occupation_local_habitation")
        end

        def situation_occupation_vacant_tlv?
          @report.situation_occupation == "vacant_tlv"
        end

        def situation_occupation_vacant_thlv?
          @report.situation_occupation == "vacant_thlv"
        end

        def proposition_occupation_non_vacant?
          %w[RP RS RE].include?(@report.proposition_occupation)
        end

        def proposition_occupation_rs?
          @report.proposition_occupation == "RS"
        end
      end
    end
  end
end
