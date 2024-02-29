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

        def resolution_motif_choices
          if @report.applicable? || @report.approved?
            I18n.t("enum.resolution_motif_applicable").map(&:reverse)
          else
            I18n.t("enum.resolution_motif_inapplicable").map(&:reverse)
          end
        end
      end
    end
  end
end
