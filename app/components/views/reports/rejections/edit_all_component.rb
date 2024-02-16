# frozen_string_literal: true

module Views
  module Reports
    module Rejections
      class EditAllComponent < ApplicationViewComponent
        def initialize(reports, selected: nil, service: nil, referrer: nil)
          @reports  = reports
          @selected = selected
          @service  = service
          @referrer = referrer
          super()
        end

        def reports_count
          @reports_count ||= @reports.count
        end

        def selected_count
          @selected_count ||= @selected || reports_count
        end

        def accepted_count
          @accepted_count ||= @reports.accepted.count
        end

        def ignored_count
          @ignored_count ||= selected_count - reports_count
        end
      end
    end
  end
end
