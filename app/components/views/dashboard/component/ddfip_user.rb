# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class DDFIPUser < self
        def waiting_for_resolution_count
          @reports.assigned.count
        end

        def resolved_count
          @reports.resolved.count
        end

        def reports_waiting_for_resolution
          @reports.waiting_for_resolution.order(assigned_at: :desc).limit(10)
        end
      end
    end
  end
end
