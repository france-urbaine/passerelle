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

    # Update invalid resolution motifs, when it could be updated
    execute <<~SQL.squish
      UPDATE  reports
      SET     resolution_motif = 'maj_occupation'
      WHERE   form_type        = 'occupation_local_habitation'
        AND   resolution_motif = 'maj_local'
    SQL

    # Reset any other resolved reports with invalid motifs
    execute <<~SQL.squish
      UPDATE  reports
      SET     state = 'assigned', resolution_motif = NULL
      WHERE   state IN ('applicable', 'approved')
        AND   (
                   (form_type = 'occupation_local_habitation' AND resolution_motif IN ('maj_exoneration', 'doublon'))
                OR (form_type = 'occupation_local_professionnel')
              )
    SQL

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

    # Reset any invalid motif
    execute <<~SQL.squish
      UPDATE  reports
      SET     state = 'assigned', resolution_motif = NULL
      WHERE   resolution_motif IN ('maj_occupation', 'application_majoration_ths')
    SQL

    change_column :reports, :resolution_motif, :enum,
      enum_type: :resolution_motif,
      using:     "resolution_motif::resolution_motif"
  end
end
