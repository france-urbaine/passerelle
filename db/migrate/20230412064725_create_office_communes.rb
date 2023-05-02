# frozen_string_literal: true

class CreateOfficeCommunes < ActiveRecord::Migration[7.0]
  def change
    create_table :office_communes, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :office, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string     :code_insee, null: false
      t.timestamps

      t.index :code_insee
      t.index %i[office_id code_insee], unique: true
    end
  end
end
