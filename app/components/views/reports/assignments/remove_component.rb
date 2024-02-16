# frozen_string_literal: true

module Views
  module Reports
    module Assignments
      class RemoveComponent < ApplicationViewComponent
        def initialize(report, referrer: nil)
          @report   = report
          @referrer = referrer
          super()
        end
      end
    end
  end
end
