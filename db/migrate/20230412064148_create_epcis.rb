# frozen_string_literal: true

class CreateEPCIs < ActiveRecord::Migration[7.0]
  def change
    create_enum :epci_nature, %w[ME CC CA CU]

    create_table :epcis, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,  null: false
      t.string :siren, null: false
      t.string :code_departement
      t.enum   :nature, enum_type: "epci_nature"

      t.timestamps

      t.integer :communes_count,       null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0

      t.index :siren, unique: true
      t.index :code_departement

      t.foreign_key :departements, column: :code_departement, primary_key: :code_departement

      t.check_constraint "communes_count >= 0",       name: "communes_count_check"
      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
    end
  end
end
