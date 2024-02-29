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

        def resolution_motif_choices
          if @state == "applicable"
            I18n.t("enum.resolution_motif_applicable").map(&:reverse)
          else
            I18n.t("enum.resolution_motif_inapplicable").map(&:reverse)
          end
        end

        def resolution_motif_options
          if resolution_motif_choices.size > 1
            { prompt: "Sélectionnez un motif" }
          else
            {}
          end
        end
      end
    end
  end
end
