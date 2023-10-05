# frozen_string_literal: true

module Views
  module Reports
    class ShowReportNameComponent < ApplicationViewComponent
      def initialize(report)
        @report = report
        super()
      end

      def call
        I18n.t(
          @report.form_type,
          scope: i18n_scope,
          address: situation_adresse,
          invariant: @report.situation_invariant
        )
      end

      def i18n_scope
        scope =
          if @report.situation_invariant? && !@report.form_type.start_with?("creation_local_")
            "with_invariant"
          elsif situation_adresse.present?
            "with_address"
          else
            "blank"
          end

        [*i18n_component_path, scope]
      end

      def situation_adresse
        @situation_adresse ||=
          if @report.situation_adresse?
            @report.situation_adresse
          elsif @report.situation_libelle_voie?
            [
              @report.situation_numero_voie,
              @report.situation_indice_repetition,
              @report.situation_libelle_voie
            ].join(" ").squish
          end
      end
    end
  end
end
