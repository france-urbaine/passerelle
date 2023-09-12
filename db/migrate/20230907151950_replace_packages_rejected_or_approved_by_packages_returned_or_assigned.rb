# frozen_string_literal: true

class ReplacePackagesRejectedOrApprovedByPackagesReturnedOrAssigned < ActiveRecord::Migration[7.0]
  def change
    rename_column :collectivities, :packages_rejected_count, :packages_returned_count
    rename_column :collectivities, :packages_approved_count, :packages_assigned_count
    rename_column :publishers, :packages_rejected_count, :packages_returned_count
    rename_column :publishers, :packages_approved_count, :packages_assigned_count
    rename_column :dgfips, :reports_published_count, :reports_delivered_count
    rename_column :ddfips, :auto_approve_packages, :auto_assign_packages
    rename_column :packages, :approved_at, :assigned_at
    rename_column :packages, :rejected_at, :returned_at

    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1
    drop_trigger :trigger_reports_changes,  on: :reports, revert_to_version: 1

    drop_function   :get_packages_rejected_count_in_collectivities, revert_to_version: 1
    drop_function   :get_packages_rejected_count_in_publishers, revert_to_version: 2
    drop_function   :get_reports_published_count_in_dgfips, revert_to_version: 1
    drop_function   :get_packages_approved_count_in_collectivities, revert_to_version: 1
    drop_function   :get_packages_approved_count_in_publishers, revert_to_version: 2

    create_function :get_packages_returned_count_in_collectivities, revert_to_version: 1
    create_function :get_packages_returned_count_in_publishers, revert_to_version: 1
    create_function :get_reports_delivered_count_in_dgfips, revert_to_version: 1
    create_function :get_packages_assigned_count_in_collectivities, revert_to_version: 1
    create_function :get_packages_assigned_count_in_publishers, revert_to_version: 1

    update_function :trigger_packages_changes, version: 8, revert_to_version: 7
    update_function :trigger_reports_changes, version: 9, revert_to_version: 8
    update_function :get_reports_approved_count_in_offices, version: 3, revert_to_version: 2
    update_function :get_reports_count_in_offices, version: 3, revert_to_version: 2
    update_function :get_reports_debated_count_in_offices, version: 3, revert_to_version: 2
    update_function :get_reports_pending_count_in_offices, version: 2, revert_to_version: 1
    update_function :get_reports_rejected_count_in_offices, version: 3, revert_to_version: 2
    update_function :get_reports_approved_count_in_ddfips, version: 2, revert_to_version: 1
    update_function :get_reports_count_in_ddfips, version: 2, revert_to_version: 1
    update_function :get_reports_debated_count_in_ddfips, version: 2, revert_to_version: 1
    update_function :get_reports_pending_count_in_ddfips, version: 2, revert_to_version: 1
    update_function :get_reports_rejected_count_in_ddfips, version: 2, revert_to_version: 1

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
