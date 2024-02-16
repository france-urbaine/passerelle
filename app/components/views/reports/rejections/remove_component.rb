# frozen_string_literal: true

module Views
  module Reports
    module Rejections
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
