# frozen_string_literal: true

class AddResolutionMotifToReport < ActiveRecord::Migration[7.1]
  def change
    create_enum :resolution_motif, %w[maj_local absence_incoherence enjeu_insuffisant]

    change_table :reports, bulk: true do |t|
      t.column :resolution_motif, :enum, enum_type: :resolution_motif
    end

    up_only do
      execute <<-SQL.squish
        UPDATE reports SET resolution_motif = 'maj_local' WHERE state IN ('applicable', 'approved');
        UPDATE reports SET resolution_motif = 'absence_incoherence' WHERE state IN ('inapplicable', 'canceled');
      SQL
    end
  end
end
