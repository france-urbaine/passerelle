# frozen_string_literal: true

class CreateCollectivities < ActiveRecord::Migration[7.0]
  def change
    create_table :collectivities, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :territory, type: :uuid, null: false, polymorphic: true
      t.references :publisher, type: :uuid, null: true

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

      t.index :name,  unique: true, where: "discarded_at IS NULL"
      t.index :siren, unique: true, where: "discarded_at IS NULL"
      t.index :discarded_at
    end
  end
end
