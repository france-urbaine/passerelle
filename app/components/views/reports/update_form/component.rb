# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Component < ApplicationViewComponent
        FIELDS = %w[
          priority
          anomalies
          situation_majic
          situation_evaluation
          proposition_evaluation
          proposition_adresse
          observations
          enjeu
        ].freeze

        def initialize(report, fields)
          raise ArgumentError, "unexpected fields: #{fields}" unless FIELDS.include?(fields)

          @report = report
          @fields = fields
          super()
        end

        private

        def fields_component
          "Views::Reports::UpdateForm::Fields::#{@fields.camelize}".constantize.new(@report)
        end
      end
    end
  end
end
