# frozen_string_literal: true

class ImproveCounterFunctionsAndTriggers < ActiveRecord::Migration[7.0]
  def change
    create_function :get_collectivities_users_count,        version: 2
    create_function :get_communes_collectivities_count,     version: 2
    create_function :get_ddfips_collectivities_count,       version: 2
    create_function :get_ddfips_users_count,                version: 2
    create_function :get_departements_collectivities_count, version: 2
    create_function :get_departements_communes_count,       version: 2
    create_function :get_departements_ddfips_count,         version: 2
    create_function :get_departements_epcis_count,          version: 2
    create_function :get_epcis_collectivities_count,        version: 2
    create_function :get_epcis_communes_count,              version: 2
    create_function :get_publishers_collectivities_count,   version: 2
    create_function :get_publishers_users_count,            version: 2
    create_function :get_regions_collectivities_count,      version: 2
    create_function :get_regions_communes_count,            version: 2
    create_function :get_regions_ddfips_count,              version: 2
    create_function :get_regions_departements_count,        version: 2
    create_function :get_regions_epcis_count,               version: 2

    update_function :reset_all_collectivities_counters, version: 2, revert_to_version: 1
    update_function :reset_all_communes_counters,       version: 2, revert_to_version: 1
    update_function :reset_all_ddfips_counters,         version: 2, revert_to_version: 1
    update_function :reset_all_departements_counters,   version: 2, revert_to_version: 1
    update_function :reset_all_epcis_counters,          version: 2, revert_to_version: 1
    update_function :reset_all_publishers_counters,     version: 2, revert_to_version: 1
    update_function :reset_all_regions_counters,        version: 2, revert_to_version: 1

    drop_trigger :trigger_collectivities_changes, on: :collectivities, revert_to_version: 1
    drop_trigger :trigger_communes_changes,       on: :communes,       revert_to_version: 1
    drop_trigger :trigger_ddfips_changes,         on: :ddfips,         revert_to_version: 1
    drop_trigger :trigger_departements_changes,   on: :departements,   revert_to_version: 1
    drop_trigger :trigger_epcis_changes,          on: :epcis,          revert_to_version: 1
    drop_trigger :trigger_users_changes,          on: :users,          revert_to_version: 1

    update_function :trigger_collectivities_changes, version: 2, revert_to_version: 1
    update_function :trigger_communes_changes,       version: 2, revert_to_version: 1
    update_function :trigger_ddfips_changes,         version: 2, revert_to_version: 1
    update_function :trigger_departements_changes,   version: 2, revert_to_version: 1
    update_function :trigger_epcis_changes,          version: 2, revert_to_version: 1
    update_function :trigger_users_changes,          version: 2, revert_to_version: 1

    create_trigger :trigger_collectivities_changes, on: :collectivities, version: 1
    create_trigger :trigger_communes_changes,       on: :communes,       version: 1
    create_trigger :trigger_ddfips_changes,         on: :ddfips,         version: 1
    create_trigger :trigger_departements_changes,   on: :departements,   version: 1
    create_trigger :trigger_epcis_changes,          on: :epcis,          version: 1
    create_trigger :trigger_users_changes,          on: :users,          version: 1
  end
end
