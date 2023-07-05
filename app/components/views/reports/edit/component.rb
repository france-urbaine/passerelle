# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Component < ApplicationViewComponent
        FORMS = %w[
          information
          situation_majic
          situation_evaluation
          proposition_evaluation
          proposition_exoneration
          proposition_adresse
          observations
          enjeu
        ].freeze

        def initialize(report, form, redirection_path: nil)
          raise ArgumentError, "unexpected form: #{form}" unless FORMS.include?(form)

          @report = report
          @form   = form
          @redirection_path = redirection_path
          super()
        end

        def call
          render form_component
        end

        private

        def form_component
          "Views::Reports::Edit::Form::#{@form.camelize}".constantize.new(
            @report,
            redirection_path: @redirection_path
          )
        end
      end
    end
  end
end
