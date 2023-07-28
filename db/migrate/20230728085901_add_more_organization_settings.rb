# frozen_string_literal: true

class AddMoreOrganizationSettings < ActiveRecord::Migration[7.0]
  def change
    change_table :ddfips do |t|
      t.boolean :auto_approve_packages, null: false, default: false
    end

    change_table :collectivities do |t|
      t.boolean :allow_publisher_management, null: false, default: false
    end
  end
end
