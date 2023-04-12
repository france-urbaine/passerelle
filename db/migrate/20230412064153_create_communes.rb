# frozen_string_literal: true

class CreateCommunes < ActiveRecord::Migration[7.0]
  def change
    create_table :communes, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_insee,       null: false
      t.string :code_departement, null: false
      t.string :siren_epci
      t.string :qualified_name

      t.timestamps

      t.integer :collectivities_count, null: false, default: 0
      t.integer :offices_count,        null: false, default: 0

      t.index :code_insee, unique: true
      t.index :code_departement
      t.index :siren_epci

      t.foreign_key :departements, column: :code_departement, primary_key: :code_departement
      t.foreign_key :epcis,        column: :siren_epci, primary_key: :siren, on_update: :cascade

      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
      t.check_constraint "offices_count >= 0",        name: "offices_count_check"
    end
  end
end
