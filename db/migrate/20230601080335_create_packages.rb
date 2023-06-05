# frozen_string_literal: true

class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages, id: :uuid, default: "gen_random_uuid()" do |t|
      t.belongs_to :collectivity, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :publisher,    type: :uuid, null: true, foreign_key: { on_delete: :cascade }

      t.string :name,      null: false
      t.string :reference, null: false
      t.enum   :action,    null: false, enum_type: "action"

      t.timestamps
      t.datetime :transmitted_at
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :discarded_at
      t.date     :due_on

      t.index :discarded_at
      t.index :reference, unique: true
    end
  end
end
