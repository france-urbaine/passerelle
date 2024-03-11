# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Component < ApplicationViewComponent
        FORMS = %w[
          information
          situation_majic
          situation_parcelle
          situation_evaluation
          situation_occupation
          proposition_evaluation
          proposition_exoneration
          proposition_adresse
          proposition_creation_local
          proposition_occupation
          observations
          enjeu
          response
          note
        ].freeze

        def initialize(report, form, referrer: nil)
          raise ArgumentError, "unexpected form: #{form}" unless FORMS.include?(form)

          @report   = report
          @form     = form
          @referrer = referrer
          super()
        end

        def call
          render form_component
        end

        private

        def form_component
          "Views::Reports::Edit::FormComponent::#{@form.camelize}".constantize.new(@report, referrer: @referrer)
        end
      end
    end
  end
end
