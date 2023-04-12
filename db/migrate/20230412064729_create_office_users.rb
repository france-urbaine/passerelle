# frozen_string_literal: true

class CreateOfficeUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :office_users, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :office, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,   type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps

      t.index %i[office_id user_id], unique: true
    end
  end
end
