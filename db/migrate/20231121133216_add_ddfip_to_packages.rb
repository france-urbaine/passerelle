# frozen_string_literal: true

class AddDDFIPToPackages < ActiveRecord::Migration[7.0]
  def change
    drop_trigger :trigger_packages_changes, on: :packages, revert_to_version: 1
    add_reference :packages, :ddfip, type: :uuid, foreign_key: { on_delete: :nullify }

    up_only do
      execute <<-SQL.squish
          UPDATE packages
          SET    ddfip_id = ddfips.id
          FROM   reports
          INNER JOIN communes ON communes.code_insee = reports.code_insee
          INNER JOIN ddfips ON communes.code_departement = ddfips.code_departement
          WHERE  reports.package_id = packages.id
      SQL
    end

    create_trigger :trigger_packages_changes, on: :packages
  end
end
