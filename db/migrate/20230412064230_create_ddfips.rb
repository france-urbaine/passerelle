# frozen_string_literal: true

class CreateDDFIPs < ActiveRecord::Migration[7.0]
  def change
    create_table :ddfips, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_departement, null: false

      t.timestamps
      t.datetime :discarded_at

      t.integer :users_count,          null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
      t.integer :offices_count,        null: false, default: 0

      t.index :name, unique: true, where: "discarded_at IS NULL"
      t.index :code_departement
      t.index :discarded_at

      t.foreign_key :departements, column: :code_departement, primary_key: :code_departement

      t.check_constraint "users_count >= 0",          name: "users_count_check"
      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
      t.check_constraint "offices_count >= 0",        name: "offices_count_check"
    end
  end
end
