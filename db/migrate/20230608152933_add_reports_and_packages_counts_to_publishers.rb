# frozen_string_literal: true

class AddReportsAndPackagesCountsToPublishers < ActiveRecord::Migration[7.0]
  def change
    change_table :publishers, bulk: true do |t|
      t.integer :reports_count,           null: false, default: 0
      t.integer :reports_approved_count,  null: false, default: 0
      t.integer :reports_rejected_count,  null: false, default: 0
      t.integer :reports_debated_count,   null: false, default: 0

      t.integer :packages_count,          null: false, default: 0
      t.integer :packages_approved_count, null: false, default: 0
      t.integer :packages_rejected_count, null: false, default: 0
    end

    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1

    create_function :get_reports_count_in_publishers
    create_function :get_reports_approved_count_in_publishers
    create_function :get_reports_rejected_count_in_publishers
    create_function :get_reports_debated_count_in_publishers

    create_function :get_packages_count_in_publishers
    create_function :get_packages_approved_count_in_publishers
    create_function :get_packages_rejected_count_in_publishers

    update_function :reset_all_publishers_counters, version: 2, revert_to_version: 1

    create_function :trigger_packages_changes
    update_function :trigger_reports_changes, version: 2, revert_to_version: 1

    create_trigger  :trigger_packages_changes, on: :packages
    create_trigger  :trigger_reports_changes,  on: :reports

    up_only do
      execute <<~SQL.squish
        DELETE FROM schema_migrations
        WHERE version IN ('20230608153411', '20230609093353', '20230609094310', '20230609120619')
      SQL

      execute <<~SQL.squish
        SELECT reset_all_publishers_counters()
      SQL
    end
  end
end
