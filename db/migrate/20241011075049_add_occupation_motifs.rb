# frozen_string_literal: true

class AddOccupationMotifs < ActiveRecord::Migration[7.2]
  def up
    change_column :reports, :resolution_motif, :string

    drop_enum   :resolution_motif
    create_enum :resolution_motif, %w[
      maj_local
      maj_exoneration
      maj_occupation
      application_majoration_ths
      doublon
      absence_incoherence
    ]

    change_column :reports, :resolution_motif, :enum,
      enum_type: :resolution_motif,
      using:     "resolution_motif::resolution_motif"
  end

  def down
    change_column :reports, :resolution_motif, :string

    drop_enum   :resolution_motif
    create_enum :resolution_motif, %w[
      maj_local
      maj_exoneration
      absence_incoherence
      doublon
    ]

    change_column :reports, :resolution_motif, :enum,
      enum_type: :resolution_motif,
      using:     "resolution_motif::resolution_motif"
  end
end
