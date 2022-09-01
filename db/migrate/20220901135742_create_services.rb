# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_enum :action, %w[
      evaluation_hab
      evaluation_eco
      occupation_hab
      occupation_eco
    ]

    create_table :services, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :ddfip, type: :uuid

      t.string :name,   null: false
      t.enum   :action, null: false, enum_type: "action"

      t.timestamps
      t.datetime :discarded_at

      t.integer :users_count,    null: false, default: 0
      t.integer :communes_count, null: false, default: 0

      t.index :discarded_at
    end

    change_table :ddfips do |t|
      t.integer :services_count, null: false, default: 0
    end
  end
end
