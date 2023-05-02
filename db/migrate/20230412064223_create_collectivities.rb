# frozen_string_literal: true

class CreateCollectivities < ActiveRecord::Migration[7.0]
  def change
    create_enum :collectivity_territory_type, %w[Commune EPCI Departement Region]

    create_table :collectivities, id: :uuid, default: "gen_random_uuid()" do |t|
      t.enum :territory_type, enum_type: "collectivity_territory_type", null: false
      t.uuid :territory_id, null: false
      t.index %i[territory_type territory_id], name: "index_collectivities_on_territory"

      t.references :publisher, type: :uuid, null: true, foreign_key: true

      t.string :name,  null: false
      t.string :siren, null: false

      t.string :contact_first_name
      t.string :contact_last_name
      t.string :contact_email
      t.string :contact_phone

      t.timestamps
      t.datetime :approved_at
      t.datetime :disapproved_at
      t.datetime :desactivated_at
      t.datetime :discarded_at

      t.integer :users_count, null: false, default: 0

      t.index :name,  unique: true, where: "discarded_at IS NULL"
      t.index :siren, unique: true, where: "discarded_at IS NULL"
      t.index :discarded_at

      t.check_constraint "users_count >= 0", name: "users_count_check"
    end
  end
end
