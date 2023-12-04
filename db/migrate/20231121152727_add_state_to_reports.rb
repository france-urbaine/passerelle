# frozen_string_literal: true

class AddStateToReports < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1

    add_column :reports, :state, :string, default: "draft"
    add_index :reports, :state

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE reports
          SET state = 'ready'
          WHERE state = 'draft'
            AND transmitted_at IS NULL
            AND ready_at       IS NOT NULL
        SQL

        execute <<-SQL.squish
          UPDATE reports
          SET state = 'sent'
          WHERE transmitted_at IS NOT NULL
            AND assigned_at IS NULL
            AND denied_at   IS NULL
        SQL

        execute <<-SQL.squish
          UPDATE reports
          SET state = 'denied'
          WHERE transmitted_at IS NOT NULL
            AND denied_at IS NOT NULL
        SQL

        execute <<-SQL.squish
          UPDATE reports
          SET state = 'processing'
          WHERE transmitted_at IS NOT NULL
            AND assigned_at IS NOT NULL
            AND denied_at   IS NULL
            AND approved_at IS NULL
            AND rejected_at IS NULL
            AND debated_at  IS NULL
        SQL

        execute <<-SQL.squish
          UPDATE reports
          SET state = 'approved'
          WHERE transmitted_at IS NOT NULL
            AND assigned_at IS NOT NULL
            AND denied_at   IS NULL
            AND approved_at IS NOT NULL
        SQL

        execute <<-SQL.squish
          UPDATE reports
          SET state = 'rejected'
          WHERE transmitted_at IS NOT NULL
            AND assigned_at IS NOT NULL
            AND denied_at   IS NULL
            AND rejected_at IS NOT NULL
        SQL
      end
    end

    create_trigger :trigger_reports_changes, on: :reports
  end
end
