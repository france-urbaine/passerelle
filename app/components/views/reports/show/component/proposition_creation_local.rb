# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component
        class PropositionCreationLocal < self
          def proposition_nature
            case @report.form_type
            when "creation_local_habitation"
              translate_enum(@report.proposition_nature, scope: "enum.creation_local_habitation_nature")
            when "creation_local_professionnel"
              translate_enum(@report.proposition_nature, scope: "enum.local_professionnel_nature")
            end
          end

          def proposition_nature_dependance
            translate_enum(@report.proposition_nature_dependance, scope: "enum.local_nature_dependance")
          end

          def proposition_categorie
            case @report.form_type
            when "creation_local_habitation"
              if proposition_nature_dependance?
                translate_enum(@report.proposition_categorie, scope: "enum.local_dependance_categorie")
              else
                translate_enum(@report.proposition_categorie, scope: "enum.local_habitation_categorie")
              end
            when "creation_local_professionnel"
              translate_enum(@report.proposition_categorie, scope: "enum.local_professionnel_categorie")
            end
          end

          def proposition_nature_dependance?
            %w[DA DM].include?(@report.proposition_nature)
          end
        end
      end
    end
  end
end
