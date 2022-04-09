# frozen_string_literal: true

class CreateDepartements < ActiveRecord::Migration[7.0]
  def change
    create_table :departements, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_departement, null: false
      t.string :code_region,      null: false

      t.timestamps

      t.index :code_departement, unique: true
      t.index :code_region
    end
  end
end
