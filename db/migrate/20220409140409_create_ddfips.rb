# frozen_string_literal: true

class CreateDdfips < ActiveRecord::Migration[7.0]
  def change
    create_table :ddfips, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,             null: false
      t.string :code_departement, null: false

      t.timestamps
      t.datetime :discarded_at

      t.index :name, unique: true, where: "discarded_at IS NULL"
      t.index :code_departement
      t.index :discarded_at
    end
  end
end
