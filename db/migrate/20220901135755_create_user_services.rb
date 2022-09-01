# frozen_string_literal: true

class CreateUserServices < ActiveRecord::Migration[7.0]
  def change
    create_table :user_services, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :user,    type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :service, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps

      t.index %i[service_id user_id], unique: true
    end

    change_table :users do |t|
      t.integer :services_count, null: false, default: 0
    end
  end
end
