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
          reports_counts.transmitted_count
        end

        def reports_unassigned_count
          reports_counts.unassigned_count
        end

        def reports_approved_count
          reports_counts.approved_count
        end

        def reports_canceled_count
          reports_counts.canceled_count
        end

        def reports_rejected_count
          reports_counts.rejected_count
        end

        def reports_counts
          @reports_counts ||=
            @reports.select(
              Arel.star.count.filter(Report.arel_table[:state].in(Report::TRANSMITTED_STATES)).as("transmitted_count").to_sql,
              Arel.star.count.filter(
                Report.arel_table[:state].in(%w[transmitted acknowledged accepted])
              ).as("unassigned_count").to_sql,
              Arel.star.count.filter(Report.arel_table[:state].eq("approved")).as("approved_count").to_sql,
              Arel.star.count.filter(Report.arel_table[:state].eq("canceled")).as("canceled_count").to_sql,
              Arel.star.count.filter(Report.arel_table[:state].eq("rejected")).as("rejected_count").to_sql
            ).reorder(nil)[0]
        end
      end
    end
  end
end
