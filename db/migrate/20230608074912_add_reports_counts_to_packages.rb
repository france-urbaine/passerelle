# frozen_string_literal: true

class AddReportsCountsToPackages < ActiveRecord::Migration[7.0]
  def change
    change_table :packages, bulk: true do |t|
      t.integer :reports_count, null: false, default: 0
      t.integer :reports_completed_count, null: false, default: 0
      t.integer :reports_approved_count, null: false, default: 0
      t.integer :reports_rejected_count, null: false, default: 0
      t.integer :reports_debated_count, null: false, default: 0
    end

    create_function :get_reports_count_in_packages
    create_function :get_reports_completed_count_in_packages
    create_function :get_reports_approved_count_in_packages
    create_function :get_reports_rejected_count_in_packages
    create_function :get_reports_debated_count_in_packages
    create_function :reset_all_packages_counters
    create_function :trigger_reports_changes
    create_trigger  :trigger_reports_changes, on: :reports

    up_only do
      execute <<~SQL.squish
        DELETE FROM schema_migrations
        WHERE version IN ('20230608080536', '20230608091017')
      SQL

      execute <<~SQL.squish
        SELECT reset_all_packages_counters()
      SQL
    end
  end
end
