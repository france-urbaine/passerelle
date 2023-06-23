# frozen_string_literal: true

class AddReportsCountsInDDFIPsAndOffices < ActiveRecord::Migration[7.0]
  def change
    change_table :ddfips, bulk: true do |t|
      t.integer :reports_count,          null: false, default: 0
      t.integer :reports_approved_count, null: false, default: 0
      t.integer :reports_rejected_count, null: false, default: 0
      t.integer :reports_debated_count,  null: false, default: 0
    end

    change_table :offices, bulk: true do |t|
      t.integer :reports_count,          null: false, default: 0
      t.integer :reports_approved_count, null: false, default: 0
      t.integer :reports_rejected_count, null: false, default: 0
      t.integer :reports_debated_count,  null: false, default: 0
    end

    drop_trigger :trigger_reports_changes,         on: :reports,  revert_to_version: 1
    drop_trigger :trigger_packages_changes,        on: :packages, revert_to_version: 1
    drop_trigger :trigger_office_communes_changes, on: :office_communes, revert_to_version: 1

    create_function :get_reports_count_in_ddfips
    create_function :get_reports_approved_count_in_ddfips
    create_function :get_reports_rejected_count_in_ddfips
    create_function :get_reports_debated_count_in_ddfips

    create_function :get_reports_count_in_offices
    create_function :get_reports_approved_count_in_offices
    create_function :get_reports_rejected_count_in_offices
    create_function :get_reports_debated_count_in_offices

    update_function :reset_all_ddfips_counters,  version: 2, revert_to_version: 1
    update_function :reset_all_offices_counters, version: 2, revert_to_version: 1

    update_function :trigger_reports_changes,  version: 5, revert_to_version: 4
    update_function :trigger_packages_changes, version: 4, revert_to_version: 3
    update_function :trigger_office_communes_changes, version: 2, revert_to_version: 1

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
