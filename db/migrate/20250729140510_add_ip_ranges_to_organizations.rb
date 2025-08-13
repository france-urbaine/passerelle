# frozen_string_literal: true

class AddIpRangesToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :ddfips, :ip_ranges, :text, array: true, null: false, default: []
    add_column :publishers, :ip_ranges, :text, array: true, null: false, default: []
    add_column :collectivities, :ip_ranges, :text, array: true, null: false, default: []
    add_column :dgfips, :ip_ranges, :text, array: true, null: false, default: []
  end
end
