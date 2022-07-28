# frozen_string_literal: true

class AddCounterTriggersToDatabase < ActiveRecord::Migration[7.0]
  def change
    create_function :trigger_communes_changes
    create_trigger  :trigger_communes_changes, on: :communes

    create_function :trigger_epcis_changes
    create_trigger  :trigger_epcis_changes, on: :epcis

    create_function :trigger_departements_changes
    create_trigger  :trigger_departements_changes, on: :departements

    create_function :trigger_collectivities_changes
    create_trigger  :trigger_collectivities_changes, on: :collectivities

    create_function :trigger_ddfips_changes
    create_trigger  :trigger_ddfips_changes, on: :ddfips

    create_function :trigger_users_changes
    create_trigger  :trigger_users_changes, on: :users
  end
end
