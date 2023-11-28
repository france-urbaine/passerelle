# frozen_string_literal: true

class AddArrondissementsToCommunes < ActiveRecord::Migration[7.0]
  def change
    change_table :communes, bulk: true do |t|
      t.string  :code_arrondissement
      t.integer :arrondissements_count, null: false, default: 0

      t.index :code_arrondissement
    end

    drop_trigger :trigger_communes_changes, on: :communes, revert_to_version: 1

    create_function :get_communes_arrondissements_count
    update_function :reset_all_communes_counters, version: 3, revert_to_version: 2
    update_function :trigger_communes_changes, version: 2, revert_to_version: 1

    create_trigger :trigger_communes_changes, on: :communes, version: 1
  end
end
