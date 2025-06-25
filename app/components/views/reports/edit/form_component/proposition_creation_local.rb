# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class PropositionCreationLocal < self
          def proposition_nature_dependance_fields(&)
            hidden = disabled = !proposition_nature_dependance?
            data = {
              switch_target:          "show",
              switch_value:           %w[DA DM].join(","),
              switch_value_separator: ","
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def proposition_nature_habitation_fields(&)
            hidden = disabled = proposition_nature_dependance?
            data = {
              switch_target:          "show",
              switch_value:           %w[AP MA].join(","),
              switch_value_separator: ","
            }

            tag.fieldset(data:, hidden:, disabled:, &)
          end

          def proposition_nature_dependance?
            %w[DA DM].include?(@report.proposition_nature)
          end

          def nature_habitation_choices
            enum_options(:creation_local_habitation_nature)
          end

          def nature_dependance_choices
            enum_options(:local_nature_dependance)
          end

          def nature_professionnel_choices
            enum_options(:local_professionnel_nature)
          end

          def categorie_habitation_choices
            enum_options(:local_habitation_categorie)
          end

          def categorie_dependance_choices
            enum_options(:local_dependance_categorie)
          end

          def categorie_professionnel_choices
            enum_options(:local_professionnel_categorie)
          end

          def proposition_date_achevement
            parse_date(@report.proposition_date_achevement) || @report.proposition_date_achevement
          end
        end
      end
    end
  end
end
