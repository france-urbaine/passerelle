# frozen_string_literal: true

class EnhanceOrganizations < ActiveRecord::Migration[7.0]
  def change
    change_table :publishers, bulk: true do |t|
      t.rename :email, :contact_email

      t.string :contact_first_name
      t.string :contact_last_name
      t.string :contact_phone

      t.string :domain_restriction
      t.boolean :allow_2fa_via_email, null: false, default: false
    end

    change_table :collectivities, bulk: true do |t|
      t.string :domain_restriction
      t.boolean :allow_2fa_via_email, null: false, default: false
    end

    change_table :ddfips, bulk: true do |t|
      t.string :contact_first_name
      t.string :contact_last_name
      t.string :contact_email
      t.string :contact_phone

      t.string :domain_restriction
      t.boolean :allow_2fa_via_email, null: false, default: false
    end
  end
end
