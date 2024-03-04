# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class DDFIPAdmin < self
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
      end
    end
  end
end
