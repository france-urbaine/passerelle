# frozen_string_literal: true

class AddUniquenessOnOffices < ActiveRecord::Migration[7.0]
  def change
    change_table :offices do |t|
      t.index %i[ddfip_id name], unique: true
    end
  end
end
