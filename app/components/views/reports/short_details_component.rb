# frozen_string_literal: true

module Views
  module Reports
    class ShortDetailsComponent < ApplicationViewComponent
      def initialize(report)
        @report = report
        super()
      end
    end
  end
end
