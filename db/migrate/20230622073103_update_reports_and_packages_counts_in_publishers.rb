# frozen_string_literal: true

class UpdateReportsAndPackagesCountsInPublishers < ActiveRecord::Migration[7.0]
  def change
    change_table :publishers do |t|
      t.rename :reports_count,  :reports_transmitted_count
      t.rename :packages_count, :packages_transmitted_count
    end

    drop_trigger :trigger_reports_changes,  on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1

    drop_function :get_reports_count_in_publishers,  revert_to_version: 1
    drop_function :get_packages_count_in_publishers, revert_to_version: 1

    create_function :get_reports_transmitted_count_in_publishers
    create_function :get_packages_transmitted_count_in_publishers

    update_function :get_reports_approved_count_in_publishers, version: 2, revert_to_version: 1
    update_function :get_reports_rejected_count_in_publishers, version: 2, revert_to_version: 1
    update_function :get_reports_debated_count_in_publishers,  version: 2, revert_to_version: 1

    update_function :get_packages_approved_count_in_publishers, version: 2, revert_to_version: 1
    update_function :get_packages_rejected_count_in_publishers, version: 2, revert_to_version: 1

    update_function :reset_all_publishers_counters, version: 3, revert_to_version: 2

    update_function :trigger_reports_changes,  version: 4, revert_to_version: 3
    update_function :trigger_packages_changes, version: 3, revert_to_version: 2

    create_trigger  :trigger_packages_changes, on: :packages
    create_trigger  :trigger_reports_changes,  on: :reports

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_publishers_counters()
      SQL
    end
  end
end
