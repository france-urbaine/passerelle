# frozen_string_literal: true

class FixReportsTriggers < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1
    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1

    change_table :packages do |t|
      t.remove :reports_completed_count, type: :integer, null: false, default: 0
    end

    drop_function :get_reports_completed_count_in_packages, revert_to_version: 2
    update_function :reset_all_packages_counters, version: 2, revert_to_version: 1

    update_function :trigger_reports_changes, version: 11, revert_to_version: 10
    update_function :trigger_packages_changes, version: 10, revert_to_version: 9
    create_trigger :trigger_reports_changes, on: :reports, version: 1
    create_trigger :trigger_packages_changes, on: :packages, version: 1
  end
end
