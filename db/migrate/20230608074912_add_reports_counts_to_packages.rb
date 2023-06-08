# frozen_string_literal: true

class AddReportsCountsToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :reports_count, :integer, null: false, default: 0
    add_column :packages, :reports_completed_count, :integer, null: false, default: 0
    add_column :packages, :reports_approved_count, :integer, null: false, default: 0
    add_column :packages, :reports_rejected_count, :integer, null: false, default: 0
    add_column :packages, :reports_debated_count, :integer, null: false, default: 0
  end
end
