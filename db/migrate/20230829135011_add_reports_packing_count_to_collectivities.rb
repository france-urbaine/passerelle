# frozen_string_literal: true

class AddReportsPackingCountToCollectivities < ActiveRecord::Migration[7.0]
  def change
    change_table :collectivities, bulk: true do |t|
      t.integer :reports_packing_count, null: false, default: 0
    end

    drop_trigger :trigger_reports_changes,  on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1

    create_function :get_reports_packing_count_in_collectivities
    update_function :reset_all_collectivities_counters, version: 3, revert_to_version: 2

    update_function :trigger_packages_changes, version: 5, revert_to_version: 4
    update_function :trigger_reports_changes,  version: 6, revert_to_version: 5

    create_trigger  :trigger_reports_changes, on: :reports
    create_trigger :trigger_packages_changes, on: :packages

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_collectivities_counters()
      SQL
    end
  end
end
