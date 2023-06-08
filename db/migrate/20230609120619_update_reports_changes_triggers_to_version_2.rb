# frozen_string_literal: true

class UpdateReportsChangesTriggersToVersion2 < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1
    update_function :trigger_reports_changes, version: 2, revert_to_version: 1
    create_trigger :trigger_reports_changes, on: :reports, version: 1
  end
end
