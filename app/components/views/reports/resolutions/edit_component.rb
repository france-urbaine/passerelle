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

        def resolution_choices
          if @state == "applicable"
            ["Mise à jour du local"]
          else
            ["Absence d’incohérence identifiée"]
          end
        end

        def resolution_options
          # { prompt: "Sélectionnez un motif" }
          {}
        end
      end
    end
  end
end
