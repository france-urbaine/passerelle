# frozen_string_literal: true

class AddReportsPendingCountsInDDFIPsAndOffices < ActiveRecord::Migration[7.0]
  def change
    change_table :ddfips, bulk: true do |t|
      t.integer :reports_pending_count, null: false, default: 0
    end

    change_table :offices, bulk: true do |t|
      t.integer :reports_pending_count, null: false, default: 0
    end

    drop_trigger :trigger_reports_changes,         on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes,        on: :packages, revert_to_version: 1
    drop_trigger :trigger_office_communes_changes, on: :office_communes, revert_to_version: 1

    create_function :get_reports_pending_count_in_ddfips
    create_function :get_reports_pending_count_in_offices

    update_function :reset_all_ddfips_counters,  version: 3, revert_to_version: 2
    update_function :reset_all_offices_counters, version: 3, revert_to_version: 2

    update_function :trigger_reports_changes,  version: 7, revert_to_version: 6
    update_function :trigger_packages_changes, version: 6, revert_to_version: 5
    update_function :trigger_office_communes_changes, version: 3, revert_to_version: 2

    create_trigger  :trigger_reports_changes,         on: :reports
    create_trigger  :trigger_packages_changes,        on: :packages
    create_trigger  :trigger_office_communes_changes, on: :office_communes

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_ddfips_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_offices_counters()
      SQL
    end
  end
end
