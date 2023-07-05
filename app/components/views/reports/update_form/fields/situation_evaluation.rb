# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields
        class SituationEvaluation < self
          def before_render
            @report.situation_date_mutation = nil if @report.situation_date_mutation.blank?
          end

          def affectation_choices
            if require_situation_evaluation_habitation?
              I18n.t("enum.affectation_local_habitation").map(&:reverse)
            elsif require_situation_evaluation_professionnel?
              I18n.t("enum.affectation_local_professionnel").map(&:reverse)
            end
          end

          def nature_choices
            if require_situation_evaluation_habitation?
              I18n.t("enum.nature_local_habitation").map(&:reverse)
            elsif require_situation_evaluation_professionnel?
              I18n.t("enum.nature_local_professionnel").map(&:reverse)
            end
          end

          def categorie_choices
            if require_situation_evaluation_habitation?
              I18n.t("enum.categorie_habitation").map(&:reverse)
            elsif require_situation_evaluation_professionnel?
              I18n.t("enum.categorie_economique").map(&:reverse)
            end
          end

          def coefficient_entretien_choices
            I18n.t("enum.coefficient_entretien").map(&:reverse)
          end

          def coefficient_situation_choices
            I18n.t("enum.coefficient_situation").map(&:reverse)
          end

          def situation_date_mutation
            parse_date(@report.situation_date_mutation)
          end

          def parse_date(date)
            return unless date&.match(ApplicationRecord::DATE_REGEXP)

            # The API might send pseudo-date without days or months
            # This helper ignores missing information to return a full date
            #
            # We don't really care because date edited through this form should have been
            # filled by datefield inputs and be full-date.
            #
            args = $LAST_MATCH_INFO.values_at(:year, :month, :day).compact.map(&:to_i)
            Date.new(*args)
          end
        end
      end
    end
  end
end
