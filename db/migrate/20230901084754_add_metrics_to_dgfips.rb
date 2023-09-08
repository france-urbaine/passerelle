# frozen_string_literal: true

class AddMetricsToDGFIPs < ActiveRecord::Migration[7.0]
  def change
    change_table :dgfips, bulk: true do |t|
      t.integer :reports_published_count, null: false, default: 0
      t.integer :reports_approved_count, null: false, default: 0
      t.integer :reports_rejected_count, null: false, default: 0
    end

    drop_trigger :trigger_reports_changes,         on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes,        on: :packages, revert_to_version: 1

    create_function :get_reports_published_count_in_dgfips
    create_function :get_reports_approved_count_in_dgfips
    create_function :get_reports_rejected_count_in_dgfips
    update_function :trigger_reports_changes, version: 8, revert_to_version: 7
    update_function :trigger_packages_changes, version: 7, revert_to_version: 6
    update_function :reset_all_dgfips_counters, version: 2, revert_to_version: 1

    create_trigger  :trigger_reports_changes,         on: :reports
    create_trigger  :trigger_packages_changes,        on: :packages

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_dgfips_counters()
      SQL
    end
  end
end
