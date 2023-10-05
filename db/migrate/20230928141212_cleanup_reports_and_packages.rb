# frozen_string_literal: true

class CleanupReportsAndPackages < ActiveRecord::Migration[7.0]
  def up
    execute "DELETE FROM schema_migrations WHERE version IN ('20230922140136')"

    change_table :reports do |t|
      t.change_null :package_id, true
      t.change_null :reference,  true

      t.datetime :new_completed_at
    end

    Report.update_all("new_completed_at = completed_at")
    Report
      .left_joins(:package)
      .where("packages.id IS NULL OR packages.transmitted_at IS NULL")
      .update_all(package_id: nil, reference: nil)

    Package.where(transmitted_at: nil).delete_all

    change_table :reports do |t|
      t.remove :completed_at
      t.rename :new_completed_at, :completed_at
    end

    change_table :packages do |t|
      t.change_null :transmitted_at, false
      t.remove :completed_at if t.column_exists?(:completed_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration if Rails.env.production?

    execute "INSERT INTO schema_migrations (version) VALUES ('20230922140136')"

    change_table :packages do |t|
      t.change_null :transmitted_at, true
      t.datetime :completed_at
    end

    Report.distinct.where(package_id: nil)
      .pluck(:collectivity_id, :form_type)
      .each do |(collectivity_id, form_type)|
        package = Package.create!(
          collectivity_id:,
          form_type:,
          reference: Packages::GenerateReferenceService.new.generate
        )

        Report.where(
          package_id: nil,
          collectivity_id:,
          form_type:
        ).find_each.with_index do |report, index|
          reference_index = index.to_s.rjust(5, "0")
          reference       = "#{package.reference}-#{reference_index}"

          report.update!(
            package_id: package.id,
            reference:  reference
          )
        end
      end

    change_table :reports do |t|
      t.change_null :package_id, false
      t.change_null :reference,  false
    end
  end
end
