# frozen_string_literal: true

class AddCounterFunctionsToDatabase < ActiveRecord::Migration[7.0]
  def change
    create_function :count_collectivities_in_communes
    create_function :count_collectivities_in_epcis
    create_function :count_collectivities_in_departements
    create_function :count_collectivities_in_regions
    create_function :count_collectivities_in_ddfips
    create_function :count_collectivities_in_publishers

    create_function :count_users_in_ddfips
    create_function :count_users_in_publishers
    create_function :count_users_in_collectivities

    create_function :count_communes_in_epcis
    create_function :count_communes_in_departements
    create_function :count_communes_in_regions
    create_function :count_epcis_in_departements
    create_function :count_epcis_in_regions
    create_function :count_departements_in_regions

    create_function :count_ddfips_in_departements
    create_function :count_ddfips_in_regions

    create_function :reset_all_communes_counters
    create_function :reset_all_epcis_counters
    create_function :reset_all_departements_counters
    create_function :reset_all_regions_counters

    create_function :reset_all_collectivities_counters
    create_function :reset_all_ddfips_counters
    create_function :reset_all_publishers_counters
  end
end
