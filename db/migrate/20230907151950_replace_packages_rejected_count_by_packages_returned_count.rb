# frozen_string_literal: true

class ReplacePackagesRejectedCountByPackagesReturnedCount < ActiveRecord::Migration[7.0]
  def change
    rename_column :collectivities, :packages_rejected_count, :packages_returned_count
    rename_column :publishers, :packages_rejected_count, :packages_returned_count
    rename_column :dgfips, :reports_published_count, :reports_delivered_count

    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1
    drop_trigger :trigger_reports_changes,  on: :reports, revert_to_version: 1

    create_function :get_packages_returned_count_in_collectivities
    create_function :get_packages_returned_count_in_publishers
    create_function :get_reports_delivered_count_in_dgfips

    drop_function   :get_packages_rejected_count_in_collectivities
    drop_function   :get_packages_rejected_count_in_publishers
    drop_function   :get_reports_published_count_in_dgfips

    update_function :trigger_packages_changes, version: 8, revert_to_version: 7
    update_function :trigger_reports_changes, version: 9, revert_to_version: 8

    update_function :reset_all_publishers_counters, version: 4, revert_to_version: 3
    update_function :reset_all_collectivities_counters, version: 4, revert_to_version: 3
    update_function :reset_all_dgfips_counters, version: 3, revert_to_version: 2

    create_trigger  :trigger_packages_changes, on: :packages
    create_trigger  :trigger_reports_changes, on: :reports

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_publishers_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_collectivities_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_dgfips_counters()
      SQL
    end
  end
end
