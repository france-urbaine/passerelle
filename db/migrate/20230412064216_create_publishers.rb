# frozen_string_literal: true

class CreatePublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :publishers, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name,  null: false
      t.string :siren, null: false
      t.string :email

      t.timestamps
      t.datetime :discarded_at

      t.integer :users_count,          null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0

      t.index :name,  unique: true, where: "discarded_at IS NULL"
      t.index :siren, unique: true, where: "discarded_at IS NULL"
      t.index :discarded_at

      t.check_constraint "users_count >= 0",          name: "users_count_check"
      t.check_constraint "collectivities_count >= 0", name: "collectivities_count_check"
    end
  end
end
