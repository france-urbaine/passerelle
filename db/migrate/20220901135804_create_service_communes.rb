# frozen_string_literal: true

class CreateServiceCommunes < ActiveRecord::Migration[7.0]
  def change
    create_table :service_communes, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :service, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string     :code_insee,           null: false
      t.timestamps

      t.index :code_insee
      t.index %i[service_id code_insee], unique: true
    end

    change_table :communes do |t|
      t.integer :services_count, null: false, default: 0
    end
  end
end
