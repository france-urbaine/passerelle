# frozen_string_literal: true

class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,        null: false
      t.string :code_region, null: false
      t.string :qualified_name

      t.timestamps

      t.integer :departements_count,   null: false, default: 0
      t.integer :epcis_count,          null: false, default: 0
      t.integer :communes_count,       null: false, default: 0
      t.integer :ddfips_count,         null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0

      t.index :code_region, unique: true

      t.check_constraint "departements_count >= 0",   name: "departements_count_check"
      t.check_constraint "epcis_count >= 0",          name: "epcis_count_check"
      t.check_constraint "communes_count >= 0",       name: "communes_count_check"
      t.check_constraint "ddfips_count >= 0",         name: "ddfips_count_check"
      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
    end
  end
end
