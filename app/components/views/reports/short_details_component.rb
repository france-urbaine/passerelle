# frozen_string_literal: true

module Views
  module Reports
    class ShortDetailsComponent < ::UI::DescriptionList::Component
      def initialize(report)
        @report = report
        super(report)
      end
    end
  end
end
