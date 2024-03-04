# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class Publisher < self
        def reports_returned_count
          current_organization.reports_approved_count +
            current_organization.reports_canceled_count +
            current_organization.reports_rejected_count
        end

        def reports_transmitted
          @reports.order(transmitted_at: :desc).limit(10)
        end
      end
    end
  end
end
