# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class Information < self
          ANOMALIES_ENABLED = {
            "consistance"        => true,
            "affectation"        => true,
            "categorie"          => true,
            "correctif"          => true,
            "exoneration"        => true,
            "adresse"            => true,
            "omission_batie"     => true,
            "construction_neuve" => true,
            "occupation"         => true
          }.freeze

          def form_type_anomalies
            Report::FORM_TYPE_ANOMALIES.fetch(@report.form_type, [])
          end

          def anomalies_choices
            form_type_anomalies
              .sort_by { |key| ANOMALIES_ENABLED[key] ? 0 : 1 }
              .map do |key|
                enabled = ANOMALIES_ENABLED[key]
                name = I18n.t(key, scope: ["enum.anomalies", @report.form_type])
                name = "(Bientôt disponible) #{name}" unless enabled
                [key, name]
              end
          end

          def anomalies_disabled
            form_type_anomalies.reject { |key| ANOMALIES_ENABLED[key] }
          end

          def anomalies_exclusive?
            @report.form_type.start_with?("creation_local_")
          end

          def priority_choices
            enum_options(:priority)
          end
        end
      end
    end
  end
end
