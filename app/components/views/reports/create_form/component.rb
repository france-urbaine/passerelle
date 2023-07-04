# frozen_string_literal: true

module Views
  module Reports
    module CreateForm
      class Component < ApplicationViewComponent
        def initialize(report)
          @report = report
          super()
        end

        FORM_TYPE_ENABLED = {
          "evaluation_local_habitation"    => true,
          "evaluation_local_professionnel" => true,
          "creation_local_habitation"      => false,
          "creation_local_professionnel"   => false,
          "occupation_local_habitation"    => false,
          "occupation_local_professionnel" => false
        }.freeze

        def form_type_choices
          Report::FORM_TYPES
            .sort_by { |key| FORM_TYPE_ENABLED[key] ? 0 : 1 }
            .map do |key|
              enabled = FORM_TYPE_ENABLED[key]
              name = I18n.t(key, scope: "enum.report_form_type")
              name = "(Bientôt disponible) #{name}" unless enabled
              [name, key]
            end
        end

        def form_type_disabled
          FORM_TYPE_ENABLED.keys.reject { |key| FORM_TYPE_ENABLED[key] }
        end
      end
    end
  end
end
