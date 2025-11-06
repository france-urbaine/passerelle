# frozen_string_literal: true

class AddFormAdminAndOfficeUserToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :form_admin,  null: false, default: false
      t.boolean :office_user, null: false, default: false
    end
  end
end
