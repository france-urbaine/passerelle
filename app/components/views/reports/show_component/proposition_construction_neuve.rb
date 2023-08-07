# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class PropositionConstructionNeuve < self
        def proposition_nature
          case @report.form_type
          when "creation_local_habitation"
            t(@report.proposition_nature, scope: "enum.creation_local_habitation_nature")
          when "creation_local_professionnel"
            t(@report.proposition_nature, scope: "enum.local_professionnel_nature")
          end
        end

        def proposition_nature_dependance
          t(@report.proposition_nature_dependance, scope: "enum.local_nature_dependance")
        end

        def proposition_categorie
          case @report.form_type
          when "creation_local_habitation"
            t(@report.proposition_categorie, scope: "enum.local_habitation_categorie")
          when "creation_local_professionnel"
            t(@report.proposition_categorie, scope: "enum.local_professionnel_categorie")
          end
        end
      end
    end
  end
end
