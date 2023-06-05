# frozen_string_literal: true

class CreateWorkshops < ActiveRecord::Migration[7.0]
  def change
    create_table :workshops, id: :uuid, default: "gen_random_uuid()" do |t|
      t.belongs_to :ddfip, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.string :name, null: false

      t.timestamps
      t.datetime :discarded_at
      t.date     :due_on

      t.index :discarded_at
    end
  end
end
