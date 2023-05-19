# frozen_string_literal: true

class UpdateEmailUniqueConstraintsOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.remove_index :email, unique: true
      t.index :email, unique: true, where: "discarded_at IS NULL"
    end
  end
end
