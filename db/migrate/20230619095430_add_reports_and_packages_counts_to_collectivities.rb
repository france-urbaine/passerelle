# frozen_string_literal: true

class AddReportsAndPackagesCountsToCollectivities < ActiveRecord::Migration[7.0]
  def change
    change_table :collectivities, bulk: true do |t|
      t.integer :reports_transmitted_count, null: false, default: 0
      t.integer :reports_approved_count,    null: false, default: 0
      t.integer :reports_rejected_count,    null: false, default: 0
      t.integer :reports_debated_count,     null: false, default: 0

      t.integer :packages_transmitted_count, null: false, default: 0
      t.integer :packages_approved_count,    null: false, default: 0
      t.integer :packages_rejected_count,    null: false, default: 0
    end

    drop_trigger :trigger_reports_changes,  on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1

    create_function :get_reports_transmitted_count_in_collectivities
    create_function :get_reports_approved_count_in_collectivities
    create_function :get_reports_rejected_count_in_collectivities
    create_function :get_reports_debated_count_in_collectivities

    create_function :get_packages_transmitted_count_in_collectivities
    create_function :get_packages_approved_count_in_collectivities
    create_function :get_packages_rejected_count_in_collectivities

    update_function :reset_all_collectivities_counters, version: 2, revert_to_version: 1

    update_function :trigger_packages_changes, version: 2, revert_to_version: 1
    update_function :trigger_reports_changes, version: 3, revert_to_version: 2

    create_trigger  :trigger_packages_changes, on: :packages
    create_trigger  :trigger_reports_changes,  on: :reports

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_collectivities_counters()
      SQL
    end
  end
end
