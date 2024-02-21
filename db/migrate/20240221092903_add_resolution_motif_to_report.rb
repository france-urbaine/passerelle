# frozen_string_literal: true

class AddResolutionMotifToReport < ActiveRecord::Migration[7.1]
  def change
    create_enum :resolution_motif, %w[maj_local absence_incoherence enjeu_insuffisant]

    change_table :reports, bulk: true do |t|
      t.column :resolution_motif, :enum, enum_type: :resolution_motif
    end
  end
end
