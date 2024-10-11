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

        def applicable?
          @report.applicable? || @report.approved?
        end

        def resolution_motif_choices
          enum_path = ["enum.resolution_motif"]
          enum_path << @report.form_type
          enum_path << (applicable? ? "applicable" : "inapplicable")

          I18n.t(enum_path.join("."), default: {}).map(&:reverse)
        end
      end
    end
  end
end
