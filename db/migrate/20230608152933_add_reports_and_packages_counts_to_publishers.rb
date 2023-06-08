# frozen_string_literal: true

class AddReportsAndPackagesCountsToPublishers < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :reports_count,           :integer, null: false, default: 0
    add_column :publishers, :reports_completed_count, :integer, null: false, default: 0
    add_column :publishers, :reports_approved_count,  :integer, null: false, default: 0
    add_column :publishers, :reports_rejected_count,  :integer, null: false, default: 0
    add_column :publishers, :reports_debated_count,   :integer, null: false, default: 0
    add_column :publishers, :packages_count,          :integer, null: false, default: 0
    add_column :publishers, :packages_approved_count, :integer, null: false, default: 0
    add_column :publishers, :packages_rejected_count, :integer, null: false, default: 0
  end
end
