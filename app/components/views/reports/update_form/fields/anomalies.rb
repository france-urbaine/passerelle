# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields
        class Anomalies < self
          ANOMALIES_ENABLED = {
            "consistance"        => true,
            "affectation"        => true,
            "exoneration"        => false,
            "adresse"            => true,
            "correctif"          => false,
            "omission_batie"     => false,
            "achevement_travaux" => false,
            "occupation"         => false
          }.freeze

          def form_type_anomalies
            case @report.form_type
            when /^evaluation_local_/ then Report::EVALUATION_ANOMALIES
            when /^creation_local_/   then Report::CREATION_ANOMALIES
            when /^occupation_local_/ then Report::OCCUPATION_ANOMALIES
            else []
            end
          end

          def anomalies_choices
            form_type_anomalies
              .sort_by { |key| ANOMALIES_ENABLED[key] ? 0 : 1 }
              .map do |key|
                enabled = ANOMALIES_ENABLED[key]
                name = I18n.t(key, scope: "enum.anomalies")
                name = "(Bientôt disponible) #{name}" unless enabled
                [key, name]
              end
          end

          def anomalies_disabled
            form_type_anomalies.reject { |key| ANOMALIES_ENABLED[key] }
          end
        end
      end
    end
  end
end
