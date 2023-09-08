# frozen_string_literal: true

module Views
  module Reports
    class EditComponent < ApplicationViewComponent
      FORMS = %w[
        information
        situation_majic
        situation_parcelle
        situation_evaluation
        situation_occupation
        proposition_evaluation
        proposition_exoneration
        proposition_adresse
        proposition_omission_batie
        proposition_construction_neuve
        proposition_occupation
        observations
        enjeu
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
        "Views::Reports::EditFormComponent::#{@form.camelize}".constantize.new(@report, referrer: @referrer)
      end
    end
  end
end
