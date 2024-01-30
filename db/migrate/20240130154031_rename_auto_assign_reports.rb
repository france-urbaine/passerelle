# frozen_string_literal: true

class RenameAutoAssignReports < ActiveRecord::Migration[7.1]
  def change
    rename_column :ddfips, :auto_assign_packages, :auto_assign_reports
  end
end
