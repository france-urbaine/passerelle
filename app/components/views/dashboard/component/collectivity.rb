# frozen_string_literal: true

module Views
  module Dashboard
    class Component
      class Collectivity < self
        def reports_draft
          @reports_draft ||= @reports
            .draft
            .order(created_at: :desc)
            .limit(10)
        end

        def reports_ready
          @reports_ready ||= @reports
            .ready
            .order(updated_at: :desc)
            .limit(10)
        end

        def reports_returned
          @reports_returned ||= @reports
            .returned
            .order(returned_at: :desc)
            .limit(10)
        end
      end
    end
  end
end
