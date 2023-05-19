# frozen_string_literal: true

class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[7.0]
  def change
    create_enum :otp_method, %w[2fa email]

    change_table :users, bulk: true do |t|
      t.string  :otp_secret
      t.enum    :otp_method, enum_type: "otp_method", null: false, default: "2fa"
      t.integer :consumed_timestep
      t.boolean :otp_required_for_login, null: false, default: true
    end
  end
end
