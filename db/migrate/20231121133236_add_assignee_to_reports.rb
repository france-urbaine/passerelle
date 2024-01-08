# frozen_string_literal: true

class AddAssigneeToReports < ActiveRecord::Migration[7.0]
  def change
    add_reference :reports, :assignee, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
