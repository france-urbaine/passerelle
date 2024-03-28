# frozen_string_literal: true

class UpdateReportsResolutionMotifs < ActiveRecord::Migration[7.1]
  def up
    change_column :reports, :resolution_motif, :string
    execute "UPDATE reports SET resolution_motif = 'absence_incoherence' WHERE resolution_motif = 'enjeu_insuffisant'"

    drop_enum   :resolution_motif
    create_enum :resolution_motif, %w[maj_local maj_exoneration absence_incoherence doublon]

    change_column :reports, :resolution_motif, :enum,
      enum_type: :resolution_motif,
      using:     "resolution_motif::resolution_motif"
  end

  def down
    change_column :reports, :resolution_motif, :string
    execute "UPDATE reports SET resolution_motif = 'maj_local' WHERE resolution_motif = 'maj_exoneration'"
    execute "UPDATE reports SET resolution_motif = 'maj_local' WHERE resolution_motif = 'doublon'"

    drop_enum   :resolution_motif
    create_enum :resolution_motif, %w[maj_local absence_incoherence enjeu_insuffisant]

    change_column :reports, :resolution_motif, :enum,
      enum_type: :resolution_motif,
      using:     "resolution_motif::resolution_motif"
  end
end
