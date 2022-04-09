# frozen_string_literal: true

class CreateCommunes < ActiveRecord::Migration[7.0]
  def change
    create_table :communes, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_insee,       null: false
      t.string :code_departement, null: false
      t.string :siren_epci

      t.timestamps

      t.index :code_insee, unique: true
      t.index :code_departement
      t.index :siren_epci
    end
  end
end
