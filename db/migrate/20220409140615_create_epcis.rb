# frozen_string_literal: true

class CreateEpcis < ActiveRecord::Migration[7.0]
  def change
    create_table :epcis, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,  null: false
      t.string :siren, null: false
      t.string :code_departement
      t.string :nature

      t.timestamps

      t.index :siren, unique: true
      t.index :code_departement
    end
  end
end
