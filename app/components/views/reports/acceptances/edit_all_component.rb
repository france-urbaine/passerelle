# frozen_string_literal: true

module Views
  module Reports
    module Acceptances
      class EditAllComponent < ApplicationViewComponent
        def initialize(reports, selected: nil, service: nil, referrer: nil)
          @reports  = reports
          @selected = selected
          @service  = service
          @referrer = referrer
          super()
        end

        def form_model
          # `form_with` will raise en error in Rails 8.x if `model` argument is nil.
          # See https://github.com/rails/rails/pull/49943
          @service || false
        end

        def reports_count
          @reports_count ||= @reports.count
        end

        def selected_count
          @selected_count ||= @selected || reports_count
        end

        def rejected_count
          @rejected_count ||= @reports.rejected.count
        end

        def ignored_count
          @ignored_count ||= selected_count - reports_count
        end
      end
    end
  end
end
