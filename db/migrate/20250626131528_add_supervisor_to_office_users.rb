# frozen_string_literal: true

class AddSupervisorToOfficeUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :office_users, :supervisor, :boolean, default: false, null: false
  end
end
