# frozen_string_literal: true

class AddCounterFunctionsToDatabase < ActiveRecord::Migration[7.0]
  def change
    create_function :get_collectivities_count_in_communes
    create_function :get_collectivities_count_in_ddfips
    create_function :get_collectivities_count_in_departements
    create_function :get_collectivities_count_in_epcis
    create_function :get_collectivities_count_in_publishers
    create_function :get_collectivities_count_in_regions
    create_function :get_communes_count_in_departements
    create_function :get_communes_count_in_epcis
    create_function :get_communes_count_in_offices
    create_function :get_communes_count_in_regions
    create_function :get_ddfips_count_in_departements
    create_function :get_ddfips_count_in_regions
    create_function :get_departements_count_in_regions
    create_function :get_epcis_count_in_departements
    create_function :get_epcis_count_in_regions
    create_function :get_offices_count_in_communes
    create_function :get_offices_count_in_ddfips
    create_function :get_offices_count_in_users
    create_function :get_users_count_in_collectivities
    create_function :get_users_count_in_ddfips
    create_function :get_users_count_in_offices
    create_function :get_users_count_in_publishers

    create_function :reset_all_collectivities_counters
    create_function :reset_all_communes_counters
    create_function :reset_all_ddfips_counters
    create_function :reset_all_departements_counters
    create_function :reset_all_epcis_counters
    create_function :reset_all_offices_counters
    create_function :reset_all_publishers_counters
    create_function :reset_all_regions_counters
    create_function :reset_all_users_counters
  end
end
