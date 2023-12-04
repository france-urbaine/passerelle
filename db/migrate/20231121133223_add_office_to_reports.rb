# frozen_string_literal: true

class AddOfficeToReports < ActiveRecord::Migration[7.0]
  def change
    add_reference :reports, :office, type: :uuid, foreign_key: { on_delete: :nullify }

    up_only do
      drop_trigger :trigger_reports_changes, on: :reports, revert_to_version: 1

      execute <<-SQL.squish
          UPDATE reports
          SET    office_id = offices.id
          FROM   office_communes, offices
          WHERE  office_communes.code_insee = reports.code_insee
            AND office_communes.office_id = offices.id
            AND ARRAY[reports.form_type] <@ offices.competences
            AND reports.transmitted_at IS NOT NULL
      SQL

      create_trigger :trigger_reports_changes, on: :reports
    end
  end
end
