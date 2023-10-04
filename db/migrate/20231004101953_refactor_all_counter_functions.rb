# frozen_string_literal: true

class RefactorAllCounterFunctions < ActiveRecord::Migration[7.0]
  def change
    # First delete all triggers
    #
    drop_trigger :trigger_collectivities_changes,  on: :collectivities,  revert_to_version: 1
    drop_trigger :trigger_ddfips_changes,          on: :ddfips,          revert_to_version: 1
    drop_trigger :trigger_users_changes,           on: :users,           revert_to_version: 1

    drop_trigger :trigger_communes_changes,        on: :communes,        revert_to_version: 1
    drop_trigger :trigger_epcis_changes,           on: :epcis,           revert_to_version: 1
    drop_trigger :trigger_departements_changes,    on: :departements,    revert_to_version: 1

    drop_trigger :trigger_offices_changes,         on: :offices,         revert_to_version: 1
    drop_trigger :trigger_office_communes_changes, on: :office_communes, revert_to_version: 1
    drop_trigger :trigger_office_users_changes,    on: :office_users,    revert_to_version: 1

    drop_trigger :trigger_packages_changes,        on: :packages,        revert_to_version: 1
    drop_trigger :trigger_reports_changes,         on: :reports,         revert_to_version: 1

    # Then, add new counts & updates all counter functions
    #
    # - Collectivities

    change_table :collectivities, bulk: true do |t|
      t.remove :reports_transmitted_count,  type: :integer, null: false, default: 0
      t.remove :reports_approved_count,     type: :integer, null: false, default: 0
      t.remove :reports_rejected_count,     type: :integer, null: false, default: 0
      t.remove :reports_debated_count,      type: :integer, null: false, default: 0
      t.remove :reports_packing_count,      type: :integer, null: false, default: 0
      t.remove :packages_transmitted_count, type: :integer, null: false, default: 0
      t.remove :packages_assigned_count,    type: :integer, null: false, default: 0
      t.remove :packages_returned_count,    type: :integer, null: false, default: 0

      t.integer :reports_incomplete_count,   null: false, default: 0
      t.integer :reports_packing_count,      null: false, default: 0
      t.integer :reports_transmitted_count,  null: false, default: 0
      t.integer :reports_returned_count,     null: false, default: 0
      t.integer :reports_pending_count,      null: false, default: 0
      t.integer :reports_debated_count,      null: false, default: 0
      t.integer :reports_approved_count,     null: false, default: 0
      t.integer :reports_rejected_count,     null: false, default: 0

      t.integer :packages_transmitted_count, null: false, default: 0
      t.integer :packages_unresolved_count,  null: false, default: 0
      t.integer :packages_assigned_count,    null: false, default: 0
      t.integer :packages_returned_count,    null: false, default: 0
    end

    drop_function :get_users_count_in_collectivities,                revert_to_version: 1
    drop_function :get_reports_transmitted_count_in_collectivities,  revert_to_version: 1
    drop_function :get_reports_approved_count_in_collectivities,     revert_to_version: 1
    drop_function :get_reports_rejected_count_in_collectivities,     revert_to_version: 1
    drop_function :get_reports_debated_count_in_collectivities,      revert_to_version: 1
    drop_function :get_reports_packing_count_in_collectivities,      revert_to_version: 1
    drop_function :get_packages_transmitted_count_in_collectivities, revert_to_version: 1
    drop_function :get_packages_assigned_count_in_collectivities,    revert_to_version: 1
    drop_function :get_packages_returned_count_in_collectivities,    revert_to_version: 1

    create_function :get_collectivities_users_count
    create_function :get_collectivities_reports_incomplete_count
    create_function :get_collectivities_reports_packing_count
    create_function :get_collectivities_reports_transmitted_count
    create_function :get_collectivities_reports_returned_count
    create_function :get_collectivities_reports_pending_count
    create_function :get_collectivities_reports_debated_count
    create_function :get_collectivities_reports_approved_count
    create_function :get_collectivities_reports_rejected_count
    create_function :get_collectivities_packages_transmitted_count
    create_function :get_collectivities_packages_unresolved_count
    create_function :get_collectivities_packages_assigned_count
    create_function :get_collectivities_packages_returned_count

    update_function :reset_all_collectivities_counters, version: 5, revert_to_version: 4

    # - Publishers

    drop_function :get_users_count_in_publishers,                revert_to_version: 1
    drop_function :get_collectivities_count_in_publishers,       revert_to_version: 1
    drop_function :get_reports_transmitted_count_in_publishers,  revert_to_version: 1
    drop_function :get_reports_approved_count_in_publishers,     revert_to_version: 2
    drop_function :get_reports_rejected_count_in_publishers,     revert_to_version: 2
    drop_function :get_reports_debated_count_in_publishers,      revert_to_version: 2
    drop_function :get_packages_transmitted_count_in_publishers, revert_to_version: 1
    drop_function :get_packages_assigned_count_in_publishers,    revert_to_version: 1
    drop_function :get_packages_returned_count_in_publishers,    revert_to_version: 1

    create_function :get_publishers_users_count
    create_function :get_publishers_collectivities_count
    create_function :get_publishers_reports_transmitted_count
    create_function :get_publishers_reports_approved_count
    create_function :get_publishers_reports_rejected_count
    create_function :get_publishers_reports_debated_count
    create_function :get_publishers_packages_transmitted_count
    create_function :get_publishers_packages_assigned_count
    create_function :get_publishers_packages_returned_count

    update_function :reset_all_publishers_counters, version: 5, revert_to_version: 4

    # - DDFIPs

    change_table :ddfips, bulk: true do |t|
      t.remove :reports_count,          type: :integer, null: false, default: 0
      t.remove :reports_approved_count, type: :integer, null: false, default: 0
      t.remove :reports_rejected_count, type: :integer, null: false, default: 0
      t.remove :reports_debated_count,  type: :integer, null: false, default: 0
      t.remove :reports_pending_count,  type: :integer, null: false, default: 0

      t.integer :reports_transmitted_count,  null: false, default: 0
      t.integer :reports_returned_count,     null: false, default: 0
      t.integer :reports_pending_count,      null: false, default: 0
      t.integer :reports_debated_count,      null: false, default: 0
      t.integer :reports_approved_count,     null: false, default: 0
      t.integer :reports_rejected_count,     null: false, default: 0

      t.integer :packages_transmitted_count, null: false, default: 0
      t.integer :packages_unresolved_count,  null: false, default: 0
      t.integer :packages_assigned_count,    null: false, default: 0
      t.integer :packages_returned_count,    null: false, default: 0
    end

    drop_function :get_users_count_in_ddfips,            revert_to_version: 1
    drop_function :get_collectivities_count_in_ddfips,   revert_to_version: 1
    drop_function :get_offices_count_in_ddfips,          revert_to_version: 1
    drop_function :get_reports_count_in_ddfips,          revert_to_version: 2
    drop_function :get_reports_approved_count_in_ddfips, revert_to_version: 2
    drop_function :get_reports_rejected_count_in_ddfips, revert_to_version: 2
    drop_function :get_reports_debated_count_in_ddfips,  revert_to_version: 2
    drop_function :get_reports_pending_count_in_ddfips,  revert_to_version: 2

    create_function :get_ddfips_users_count
    create_function :get_ddfips_collectivities_count
    create_function :get_ddfips_offices_count

    create_function :get_ddfips_reports_transmitted_count
    create_function :get_ddfips_reports_returned_count
    create_function :get_ddfips_reports_pending_count
    create_function :get_ddfips_reports_debated_count
    create_function :get_ddfips_reports_approved_count
    create_function :get_ddfips_reports_rejected_count

    create_function :get_ddfips_packages_transmitted_count
    create_function :get_ddfips_packages_unresolved_count
    create_function :get_ddfips_packages_assigned_count
    create_function :get_ddfips_packages_returned_count

    update_function :reset_all_ddfips_counters, version: 4, revert_to_version: 3

    # DGFIPs

    change_table :dgfips, bulk: true do |t|
      t.remove :reports_delivered_count, type: :integer, null: false, default: 0
      t.remove :reports_approved_count,  type: :integer, null: false, default: 0
      t.remove :reports_rejected_count,  type: :integer, null: false, default: 0

      t.integer :reports_transmitted_count,  null: false, default: 0
      t.integer :reports_returned_count,     null: false, default: 0
      t.integer :reports_pending_count,      null: false, default: 0
      t.integer :reports_debated_count,      null: false, default: 0
      t.integer :reports_approved_count,     null: false, default: 0
      t.integer :reports_rejected_count,     null: false, default: 0

      t.integer :packages_transmitted_count, null: false, default: 0
      t.integer :packages_assigned_count,    null: false, default: 0
      t.integer :packages_returned_count,    null: false, default: 0
    end

    drop_function :get_users_count_in_dgfips,             revert_to_version: 1
    drop_function :get_reports_delivered_count_in_dgfips, revert_to_version: 1
    drop_function :get_reports_approved_count_in_dgfips,  revert_to_version: 1
    drop_function :get_reports_rejected_count_in_dgfips,  revert_to_version: 1

    create_function :get_dgfips_users_count
    create_function :get_dgfips_reports_transmitted_count
    create_function :get_dgfips_reports_returned_count
    create_function :get_dgfips_reports_pending_count
    create_function :get_dgfips_reports_debated_count
    create_function :get_dgfips_reports_approved_count
    create_function :get_dgfips_reports_rejected_count
    create_function :get_dgfips_packages_transmitted_count
    create_function :get_dgfips_packages_assigned_count
    create_function :get_dgfips_packages_returned_count

    update_function :reset_all_dgfips_counters, version: 4, revert_to_version: 3

    # - Offices

    change_table :offices, bulk: true do |t|
      t.remove :reports_count,          type: :integer, null: false, default: 0
      t.remove :reports_approved_count, type: :integer, null: false, default: 0
      t.remove :reports_rejected_count, type: :integer, null: false, default: 0
      t.remove :reports_debated_count,  type: :integer, null: false, default: 0
      t.remove :reports_pending_count,  type: :integer, null: false, default: 0

      t.integer :reports_assigned_count, null: false, default: 0
      t.integer :reports_pending_count,  null: false, default: 0
      t.integer :reports_debated_count,  null: false, default: 0
      t.integer :reports_approved_count, null: false, default: 0
      t.integer :reports_rejected_count, null: false, default: 0
    end

    drop_function :get_users_count_in_offices,            revert_to_version: 1
    drop_function :get_communes_count_in_offices,         revert_to_version: 1
    drop_function :get_reports_count_in_offices,          revert_to_version: 3
    drop_function :get_reports_approved_count_in_offices, revert_to_version: 3
    drop_function :get_reports_rejected_count_in_offices, revert_to_version: 3
    drop_function :get_reports_debated_count_in_offices,  revert_to_version: 3
    drop_function :get_reports_pending_count_in_offices,  revert_to_version: 2

    create_function :get_offices_users_count
    create_function :get_offices_communes_count
    create_function :get_offices_reports_assigned_count
    create_function :get_offices_reports_pending_count
    create_function :get_offices_reports_debated_count
    create_function :get_offices_reports_approved_count
    create_function :get_offices_reports_rejected_count

    update_function :reset_all_offices_counters, version: 4, revert_to_version: 3

    # - Users

    drop_function :get_offices_count_in_users, revert_to_version: 1
    create_function :get_users_offices_count
    update_function :reset_all_users_counters, version: 2, revert_to_version: 1

    # - Packages

    drop_function :get_reports_count_in_packages,           revert_to_version: 1
    drop_function :get_reports_approved_count_in_packages,  revert_to_version: 1
    drop_function :get_reports_rejected_count_in_packages,  revert_to_version: 1
    drop_function :get_reports_debated_count_in_packages,   revert_to_version: 1

    create_function :get_packages_reports_count
    create_function :get_packages_reports_approved_count
    create_function :get_packages_reports_rejected_count
    create_function :get_packages_reports_debated_count

    update_function :reset_all_packages_counters, version: 3, revert_to_version: 2

    # - Communes

    drop_function :get_collectivities_count_in_communes, revert_to_version: 1
    drop_function :get_offices_count_in_communes,        revert_to_version: 1

    create_function :get_communes_collectivities_count
    create_function :get_communes_offices_count

    update_function :reset_all_communes_counters, version: 2, revert_to_version: 1

    # - EPCIs

    drop_function :get_communes_count_in_epcis,       revert_to_version: 1
    drop_function :get_collectivities_count_in_epcis, revert_to_version: 1

    create_function :get_epcis_communes_count
    create_function :get_epcis_collectivities_count

    update_function :reset_all_epcis_counters, version: 2, revert_to_version: 1

    # - Departements

    drop_function :get_communes_count_in_departements,       revert_to_version: 1
    drop_function :get_epcis_count_in_departements,          revert_to_version: 1
    drop_function :get_ddfips_count_in_departements,         revert_to_version: 1
    drop_function :get_collectivities_count_in_departements, revert_to_version: 1

    create_function :get_departements_communes_count
    create_function :get_departements_epcis_count
    create_function :get_departements_ddfips_count
    create_function :get_departements_collectivities_count

    update_function :reset_all_departements_counters, version: 2, revert_to_version: 1

    # - Region

    drop_function :get_communes_count_in_regions,       revert_to_version: 1
    drop_function :get_epcis_count_in_regions,          revert_to_version: 1
    drop_function :get_departements_count_in_regions,   revert_to_version: 1
    drop_function :get_ddfips_count_in_regions,         revert_to_version: 1
    drop_function :get_collectivities_count_in_regions, revert_to_version: 1

    create_function :get_regions_communes_count
    create_function :get_regions_epcis_count
    create_function :get_regions_departements_count
    create_function :get_regions_ddfips_count
    create_function :get_regions_collectivities_count

    update_function :reset_all_regions_counters, version: 2, revert_to_version: 1

    # Then, update all triggered functions

    update_function :trigger_collectivities_changes, version: 2, revert_to_version: 1
    update_function :trigger_ddfips_changes,         version: 2, revert_to_version: 1
    update_function :trigger_users_changes,          version: 3, revert_to_version: 2

    update_function :trigger_communes_changes,       version: 2, revert_to_version: 1
    update_function :trigger_epcis_changes,          version: 2, revert_to_version: 1
    update_function :trigger_departements_changes,   version: 2, revert_to_version: 1

    update_function :trigger_offices_changes,         version: 2,  revert_to_version: 1
    update_function :trigger_office_communes_changes, version: 4,  revert_to_version: 3
    update_function :trigger_office_users_changes,    version: 2,  revert_to_version: 1

    update_function :trigger_packages_changes,        version: 11, revert_to_version: 10
    update_function :trigger_reports_changes,         version: 12, revert_to_version: 11

    # Finally, get back all triggers

    create_trigger :trigger_collectivities_changes,  on: :collectivities,  version: 1
    create_trigger :trigger_ddfips_changes,          on: :ddfips,          version: 1
    create_trigger :trigger_users_changes,           on: :users,           version: 1

    create_trigger :trigger_communes_changes,        on: :communes,        version: 1
    create_trigger :trigger_epcis_changes,           on: :epcis,           version: 1
    create_trigger :trigger_departements_changes,    on: :departements,    version: 1

    create_trigger :trigger_offices_changes,         on: :offices,         version: 1
    create_trigger :trigger_office_communes_changes, on: :office_communes, version: 1
    create_trigger :trigger_office_users_changes,    on: :office_users,    version: 1

    create_trigger :trigger_packages_changes,        on: :packages,        version: 1
    create_trigger :trigger_reports_changes,         on: :reports,         version: 1

    # And to conclude, update all counts

    up_only do
      execute "SELECT reset_all_packages_counters()"
      execute "SELECT reset_all_publishers_counters()"
      execute "SELECT reset_all_collectivities_counters()"
      execute "SELECT reset_all_dgfips_counters()"
      execute "SELECT reset_all_ddfips_counters()"
      execute "SELECT reset_all_offices_counters()"
    end
  end
end
