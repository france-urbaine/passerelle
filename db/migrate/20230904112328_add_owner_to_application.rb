# frozen_string_literal: true

class AddOwnerToApplication < ActiveRecord::Migration[7.0]
  def change
    change_table :oauth_applications, bulk: true do |t|
      t.uuid   :owner_id,   null: true
      t.string :owner_type, null: true

      t.index  %i[owner_id owner_type]
    end
  end
end
