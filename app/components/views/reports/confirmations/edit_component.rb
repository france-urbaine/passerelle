# frozen_string_literal: true

module Views
  module Reports
    module Confirmations
      class EditComponent < ApplicationViewComponent
        def initialize(report, referrer: nil)
          @report   = report
          @referrer = referrer
          super()
        end

        def resolution_choices
          if @report.applicable? || @report.approved?
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
