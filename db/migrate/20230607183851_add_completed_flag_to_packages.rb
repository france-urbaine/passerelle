# frozen_string_literal: true

class AddCompletedFlagToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :completed, :boolean, null: false, default: false
  end
end
