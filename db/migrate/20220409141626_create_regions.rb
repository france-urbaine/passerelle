# frozen_string_literal: true

class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,        null: false
      t.string :code_region, null: false

      t.timestamps

      t.index :code_region, unique: true
    end
  end
end
