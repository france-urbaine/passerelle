# frozen_string_literal: true

class RenameAutoAssignReports < ActiveRecord::Migration[7.1]
  def up
    # Restore a migration introduced in ef9e5f4fb, but removed in 7562e3e82
    # before it could have been migrated in production
    #
    rename_column :ddfips, :auto_assign_packages, :auto_assign_reports if column_exists?(:ddfips, :auto_assign_packages)
  end

  def down
    # Do nothing
  end
end
