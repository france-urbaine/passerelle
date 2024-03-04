# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class DGFIP < self
        def reports_transmitted
          @reports.order(transmitted_at: :desc).limit(10)
        end
      end
    end
  end
end
