# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class DDFIPFormAdmin < self
        def reports_waiting_for_acceptance
          @reports_waiting_for_acceptance ||= @reports
            .waiting_for_acceptance
            .order(transmitted_at: :desc)
            .limit(10)
        end

        def reports_waiting_for_assignment
          @reports_waiting_for_assignment ||= @reports
            .waiting_for_assignment
            .order(accepted_at: :desc)
            .limit(10)
        end

        def reports_waiting_for_confirmation
          @reports_waiting_for_confirmation ||= @reports
            .waiting_for_confirmation
            .order(resolved_at: :desc)
            .limit(10)
        end

        def reports_transmitted_count
          @reports.transmitted.count
        end

        def reports_unassigned_count
          @reports.waiting_for_assignment.merge(
            @reports.waiting_for_acceptance
          ).count
        end

        def reports_approved_count
          @reports.approved.count
        end

        def reports_canceled_count
          @reports.canceled.count
        end

        def reports_rejected_count
          @reports.rejected.count
        end
      end
    end
  end
end
