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

        def proposition_date_occupation
          parse_date(@report.proposition_date_occupation) || @report.proposition_date_occupation
        end

        def proposition_date_debut_activite
          parse_date(@report.proposition_date_debut_activite) || @report.proposition_date_debut_activite
        end
      end
    end
  end
end
