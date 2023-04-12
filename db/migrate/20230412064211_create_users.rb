# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_enum :user_organization_type, %w[Collectivity Publisher DDFIP]

    create_table :users, id: :uuid, default: "gen_random_uuid()" do |t|
      t.enum :organization_type, enum_type: "user_organization_type", null: false
      t.uuid :organization_id, null: false
      t.index %i[organization_type organization_id], name: "index_users_on_organization"

      t.references :inviter, type: :uuid

      t.string :first_name,          null: false, default: ""
      t.string :last_name,           null: false, default: ""
      t.string :name,                null: false, default: ""

      t.boolean :super_admin,        null: false, default: false
      t.boolean :organization_admin, null: false, default: false

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps
      t.datetime :invited_at
      t.datetime :discarded_at

      ## Counters
      t.integer :offices_count, null: false, default: 0

      ## Indexes
      t.index :email,                unique: true
      t.index :reset_password_token, unique: true
      t.index :confirmation_token,   unique: true
      t.index :unlock_token,         unique: true
      t.index :discarded_at
    end
  end
end
