# frozen_string_literal: true

class CreateDepartements < ActiveRecord::Migration[7.0]
  def change
    create_table :departements, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_departement, null: false
      t.string :code_region,      null: false
      t.string :qualified_name

      t.timestamps

      t.integer :epcis_count,          null: false, default: 0
      t.integer :communes_count,       null: false, default: 0
      t.integer :ddfips_count,         null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0

      t.index :code_departement, unique: true
      t.index :code_region

      t.foreign_key :regions, column: :code_region, primary_key: :code_region

      t.check_constraint "epcis_count >= 0",          name: "epcis_count_check"
      t.check_constraint "communes_count >= 0",       name: "communes_count_check"
      t.check_constraint "ddfips_count >= 0",         name: "ddfips_count_check"
      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
    end
  end
end
