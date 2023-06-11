# frozen_string_literal: true

class AddChangesTriggersToReports < ActiveRecord::Migration[7.0]
  def change
    create_function :trigger_reports_changes

    create_trigger :trigger_reports_changes, on: :reports
  end
end
