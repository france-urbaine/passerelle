# frozen_string_literal: true

module Views
  module Reports
    module Resolutions
      class EditComponent < ApplicationViewComponent
        def initialize(report, state, referrer: nil)
          raise ArgumentError unless %w[applicable inapplicable].include?(state.to_s)

          @report   = report
          @state    = state
          @referrer = referrer
          super()
        end

        def applicable?
          @state == "applicable"
        end

        def resolution_motif_choices
          enum_path = ["enum.resolution_motif"]
          enum_path << @report.form_type
          enum_path << (applicable? ? "applicable" : "inapplicable")

          I18n.t(enum_path.join("."), default: {}).map(&:reverse)
        end

        def resolution_motif_options
          if resolution_motif_choices.empty?
            { include_blank: "Aucun motif disponible" }
          elsif resolution_motif_choices.size > 1
            { prompt: "Sélectionnez un motif" }
          else
            {}
          end
        end
      end
    end
  end
end
