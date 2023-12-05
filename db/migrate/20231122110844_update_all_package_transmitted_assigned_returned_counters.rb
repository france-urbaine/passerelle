# frozen_string_literal: true

class UpdateAllPackageTransmittedAssignedReturnedCounters < ActiveRecord::Migration[7.0]
  def change
    change_table :collectivities, bulk: true do |t|
      t.remove :packages_transmitted_count, type: :integer, default: 0, null: false
      t.remove :packages_unresolved_count, type: :integer, default: 0, null: false
      t.remove :packages_assigned_count, type: :integer, default: 0, null: false
      t.remove :packages_returned_count, type: :integer, default: 0, null: false
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
      t.rename :reports_returned_count, :reports_denied_count
      t.rename :reports_pending_count, :reports_processing_count
    end

    change_table :ddfips, bulk: true do |t|
      t.remove :packages_transmitted_count, type: :integer, default: 0, null: false
      t.remove :packages_unresolved_count, type: :integer, default: 0, null: false
      t.remove :packages_assigned_count, type: :integer, default: 0, null: false
      t.remove :packages_returned_count, type: :integer, default: 0, null: false
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
      t.rename :reports_returned_count, :reports_denied_count
      t.rename :reports_pending_count, :reports_processing_count
    end

    change_table :dgfips, bulk: true do |t|
      t.remove :packages_transmitted_count, type: :integer, default: 0, null: false
      t.remove :packages_assigned_count, type: :integer, default: 0, null: false
      t.remove :packages_returned_count, type: :integer, default: 0, null: false
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
      t.rename :reports_returned_count, :reports_denied_count
      t.rename :reports_pending_count, :reports_processing_count
    end

    change_table :offices, bulk: true do |t|
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
      t.rename :reports_pending_count, :reports_processing_count
    end

    change_table :publishers, bulk: true do |t|
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
      t.remove :packages_transmitted_count, type: :integer, default: 0, null: false
      t.remove :packages_assigned_count, type: :integer, default: 0, null: false
      t.remove :packages_returned_count, type: :integer, default: 0, null: false
    end

    change_table :packages, bulk: true do |t|
      t.remove :reports_debated_count, type: :integer, default: 0, null: false
    end

    drop_trigger :trigger_office_communes_changes, on: :office_communes, revert_to_version: 1
    drop_trigger :trigger_packages_changes,        on: :packages, revert_to_version: 1
    drop_trigger :trigger_reports_changes,         on: :reports, revert_to_version: 1

    drop_function   :get_collectivities_packages_transmitted_count, revert_to_version: 1
    drop_function   :get_collectivities_packages_unresolved_count, revert_to_version: 1
    drop_function   :get_collectivities_packages_assigned_count, revert_to_version: 1
    drop_function   :get_collectivities_packages_returned_count, revert_to_version: 1

    drop_function   :get_ddfips_packages_transmitted_count, revert_to_version: 1
    drop_function   :get_ddfips_packages_unresolved_count, revert_to_version: 1
    drop_function   :get_ddfips_packages_assigned_count, revert_to_version: 1
    drop_function   :get_ddfips_packages_returned_count, revert_to_version: 1

    drop_function   :get_dgfips_packages_transmitted_count, revert_to_version: 1
    drop_function   :get_dgfips_packages_assigned_count, revert_to_version: 1
    drop_function   :get_dgfips_packages_returned_count, revert_to_version: 1

    drop_function   :get_publishers_packages_transmitted_count, revert_to_version: 1
    drop_function   :get_publishers_packages_assigned_count, revert_to_version: 1
    drop_function   :get_publishers_packages_returned_count, revert_to_version: 1

    update_function :trigger_packages_changes, version: 12, revert_to_version: 11
    update_function :trigger_reports_changes, version: 13, revert_to_version: 12

    drop_function :get_collectivities_reports_debated_count, revert_to_version: 1
    drop_function :get_ddfips_reports_debated_count, revert_to_version: 1
    drop_function :get_dgfips_reports_debated_count, revert_to_version: 1
    drop_function :get_offices_reports_debated_count, revert_to_version: 1
    drop_function :get_packages_reports_debated_count, revert_to_version: 1
    drop_function :get_publishers_reports_debated_count, revert_to_version: 1

    drop_function :get_collectivities_reports_returned_count, revert_to_version: 1
    drop_function :get_ddfips_reports_returned_count, revert_to_version: 1
    drop_function :get_dgfips_reports_returned_count, revert_to_version: 1

    create_function :get_collectivities_reports_denied_count
    create_function :get_ddfips_reports_denied_count
    create_function :get_dgfips_reports_denied_count

    drop_function :get_collectivities_reports_pending_count, revert_to_version: 1
    drop_function :get_ddfips_reports_pending_count, revert_to_version: 1
    drop_function :get_dgfips_reports_pending_count, revert_to_version: 1
    drop_function :get_offices_reports_pending_count, revert_to_version: 1

    create_function :get_collectivities_reports_processing_count
    create_function :get_ddfips_reports_processing_count
    create_function :get_dgfips_reports_processing_count
    create_function :get_offices_reports_processing_count

    update_function :get_collectivities_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_collectivities_reports_incomplete_count, version: 2, revert_to_version: 1
    update_function :get_collectivities_reports_packing_count, version: 2, revert_to_version: 1
    update_function :get_collectivities_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_collectivities_reports_transmitted_count, version: 2, revert_to_version: 1
    update_function :get_ddfips_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_ddfips_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_ddfips_reports_transmitted_count, version: 2, revert_to_version: 1
    update_function :get_dgfips_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_dgfips_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_dgfips_reports_transmitted_count, version: 2, revert_to_version: 1
    update_function :get_offices_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_offices_reports_assigned_count, version: 2, revert_to_version: 1
    update_function :get_offices_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_packages_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_packages_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_publishers_reports_approved_count, version: 2, revert_to_version: 1
    update_function :get_publishers_reports_rejected_count, version: 2, revert_to_version: 1
    update_function :get_publishers_reports_transmitted_count, version: 2, revert_to_version: 1

    update_function :reset_all_collectivities_counters, version: 6, revert_to_version: 5
    update_function :reset_all_ddfips_counters, version: 5, revert_to_version: 4
    update_function :reset_all_dgfips_counters, version: 5, revert_to_version: 4
    update_function :reset_all_publishers_counters, version: 6, revert_to_version: 5
    update_function :reset_all_offices_counters, version: 5, revert_to_version: 4
    update_function :reset_all_packages_counters, version: 4, revert_to_version: 3
    update_function :trigger_office_communes_changes, version: 4, revert_to_version: 3

    create_trigger :trigger_office_communes_changes, on: :office_communes
    create_trigger :trigger_packages_changes,        on: :packages
    create_trigger :trigger_reports_changes,         on: :reports

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_collectivities_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_publishers_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_ddfips_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_dgfips_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_offices_counters()
      SQL
    end
  end
end
