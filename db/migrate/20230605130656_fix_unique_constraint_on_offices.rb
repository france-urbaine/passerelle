# frozen_string_literal: true

class FixUniqueConstraintOnOffices < ActiveRecord::Migration[7.0]
  def change
    remove_index :offices, %i[ddfip_id name], unique: true
    add_index :offices, %i[ddfip_id name], unique: true, where: "discarded_at IS NULL"
  end
end
