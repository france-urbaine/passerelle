# frozen_string_literal: true

class CreateDGFIPs < ActiveRecord::Migration[7.0]
  def change
    create_table :dgfips, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string  :name, null: false
      t.string  :contact_first_name
      t.string  :contact_last_name
      t.string  :contact_email
      t.string  :contact_phone
      t.string  :domain_restriction
      t.boolean :allow_2fa_via_email, null: false, default: false

      t.timestamps
      t.datetime :discarded_at

      t.integer :users_count, null: false, default: 0

      t.index :name, unique: true, where: "discarded_at IS NULL"
      t.index :discarded_at

      t.check_constraint "users_count >= 0", name: "users_count_check"
    end
  end
end
