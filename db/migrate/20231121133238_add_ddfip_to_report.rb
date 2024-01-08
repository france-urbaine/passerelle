# frozen_string_literal: true

class AddDDFIPToReport < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1

    add_reference :reports, :ddfip, type: :uuid, foreign_key: { on_delete: :nullify }

    up_only do
      execute <<-SQL.squish
        UPDATE reports
        SET    ddfip_id = packages.ddfip_id
        FROM   packages
        WHERE  packages.id = reports.package_id
      SQL
    end

    create_trigger :trigger_reports_changes, on: :reports
  end
end
