# frozen_string_literal: true

class AddCounters < ActiveRecord::Migration[7.0]
  def change
    change_table :publishers, bulk: true do |t|
      t.integer :users_count,          null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
    end

    change_table :collectivities, bulk: true do |t|
      t.integer :users_count, null: false, default: 0
    end

    change_table :ddfips, bulk: true do |t|
      t.integer :users_count,          null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
    end

    change_table :communes, bulk: true do |t|
      t.integer :collectivities_count, null: false, default: 0
    end

    change_table :epcis, bulk: true do |t|
      t.integer :communes_count,       null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
    end

    change_table :departements, bulk: true do |t|
      t.integer :epcis_count,          null: false, default: 0
      t.integer :communes_count,       null: false, default: 0
      t.integer :ddfips_count,         null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
    end

    change_table :regions, bulk: true do |t|
      t.integer :departements_count,   null: false, default: 0
      t.integer :epcis_count,          null: false, default: 0
      t.integer :communes_count,       null: false, default: 0
      t.integer :ddfips_count,         null: false, default: 0
      t.integer :collectivities_count, null: false, default: 0
    end
  end
end
