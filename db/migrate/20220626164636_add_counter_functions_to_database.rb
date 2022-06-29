# frozen_string_literal: true

class AddCounterFunctionsToDatabase < ActiveRecord::Migration[7.0]
  def change
    create_function :reset_all_communes_counters
    create_function :reset_all_epcis_counters
    create_function :reset_all_departements_counters
    create_function :reset_all_regions_counters

    create_function :reset_all_collectivities_counters
    create_function :reset_all_ddfips_counters
    create_function :reset_all_publishers_counters
  end
end
