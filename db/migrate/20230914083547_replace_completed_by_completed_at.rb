# frozen_string_literal: true

class ReplaceCompletedByCompletedAt < ActiveRecord::Migration[7.0]
  def up
    change_table :packages, bulk: true do |t|
      t.datetime :completed_at
    end

    change_table :reports, bulk: true do |t|
      t.datetime :completed_at
    end

    Package.where(completed: true).update_all(completed_at: Time.current)
    Report.where(completed: true).update_all(completed_at: Time.current)

    remove_column :packages, :completed
    remove_column :reports,  :completed
  end

  def down
    change_table :packages, bulk: true do |t|
      t.boolean :completed, default: false, null: false
    end

    change_table :reports, bulk: true do |t|
      t.boolean :completed, default: false, null: false
    end

    Package.where.not(completed_at: nil).update_all(completed: true)
    Report.where.not(completed_at: nil).update_all(completed: true)

    remove_column :packages, :completed_at
    remove_column :reports,  :completed_at
  end
end
