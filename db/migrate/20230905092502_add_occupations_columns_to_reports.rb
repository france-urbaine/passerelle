# frozen_string_literal: true

class AddOccupationsColumnsToReports < ActiveRecord::Migration[7.0]
  def change
    change_table :reports, bulk: true do |t|
      t.string  :situation_occupation
      t.boolean :situation_majoration_rs, null: false, default: false

      t.integer :proposition_occupation_annee_concernee
      t.string  :proposition_occupation
      t.date    :proposition_date_occupation
      t.boolean :proposition_erreur_tlv,      null: false, default: false
      t.boolean :proposition_erreur_thlv,     null: false, default: false
      t.boolean :proposition_meuble_tourisme, null: false, default: false
      t.boolean :proposition_majoration_rs,   null: false, default: false
      t.string  :proposition_occupation_nom_occupant
      t.string  :proposition_occupation_prenom_occupant
      t.string  :proposition_occupation_adresse_occupant
    end
  end
end
