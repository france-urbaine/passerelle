# frozen_string_literal: true

class AddQualifiedNameToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,      :qualified_name, :string
    add_column :departements, :qualified_name, :string
    add_column :communes,     :qualified_name, :string
  end
end
