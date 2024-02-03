# frozen_string_literal: true

module Views
  module Reports
    module Denials
      class RemoveComponent < ApplicationViewComponent
        def initialize(report, referrer: nil)
          @report   = report
          @referrer = referrer
          super()
        end

        def redirection_path
          @referrer
        end
      end
    end
  end
end
