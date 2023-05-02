# frozen_string_literal: true

class CreateOffices < ActiveRecord::Migration[7.0]
  def change
    create_enum :office_action, %w[
      evaluation_hab
      evaluation_eco
      occupation_hab
      occupation_eco
    ]

    create_table :offices, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :ddfip, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.string :name,   null: false
      t.enum   :action, null: false, enum_type: "office_action"

      t.timestamps
      t.datetime :discarded_at

      t.integer :users_count,    null: false, default: 0
      t.integer :communes_count, null: false, default: 0

      t.index :discarded_at
    end
  end
end
