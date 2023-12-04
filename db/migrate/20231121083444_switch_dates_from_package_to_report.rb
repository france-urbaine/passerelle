# frozen_string_literal: true

class SwitchDatesFromPackageToReport < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1

    change_table :reports, bulk: true do |t|
      t.datetime :transmitted_at
      t.datetime :assigned_at
      t.datetime :denied_at
      t.rename :completed_at, :ready_at
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE reports
          SET transmitted_at = packages.transmitted_at,
              assigned_at = packages.assigned_at,
              denied_at = packages.returned_at
          FROM packages
          WHERE reports.package_id = packages.id
        SQL
      end

      dir.down do
        execute <<-SQL.squish
          UPDATE packages
          SET transmitted_at = reports.transmitted_at,
              assigned_at = reports.assigned_at,
              returned_at = reports.denied_at
          FROM reports
          WHERE reports.package_id = packages.id
        SQL
      end
    end

    change_table :packages, bulk: true do |t|
      t.remove :transmitted_at, type: :datetime
      t.remove :assigned_at, type: :datetime
      t.remove :returned_at, type: :datetime
    end

    create_trigger :trigger_reports_changes, on: :reports
  end
end
