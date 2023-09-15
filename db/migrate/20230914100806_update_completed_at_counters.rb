# frozen_string_literal: true

class UpdateCompletedAtCounters < ActiveRecord::Migration[7.0]
  def change
    drop_trigger    :trigger_reports_changes,  on: :reports, revert_to_version: 1
    drop_trigger    :trigger_packages_changes, on: :packages, revert_to_version: 1

    update_function :trigger_packages_changes, version: 9, revert_to_version: 8
    update_function :trigger_reports_changes, version: 10, revert_to_version: 9

    update_function :get_reports_completed_count_in_packages, version: 2, revert_to_version: 1

    create_trigger  :trigger_reports_changes, on: :reports
    create_trigger  :trigger_packages_changes, on: :packages

    up_only do
      execute <<~SQL.squish
        SELECT reset_all_publishers_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_collectivities_counters()
      SQL

      execute <<~SQL.squish
        SELECT reset_all_dgfips_counters()
      SQL
    end
  end
end
