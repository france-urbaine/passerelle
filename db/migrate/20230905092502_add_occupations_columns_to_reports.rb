# frozen_string_literal: true

class AddOccupationsColumnsToReports < ActiveRecord::Migration[7.0]
  def change
    change_table :reports, bulk: true do |t|
      t.string  :situation_occupation
      t.boolean :situation_majoration_rs, null: false, default: false
      t.integer :situation_annee_fichier_cfe
      t.boolean :situation_vacances_fiscales, null: false, default: false
      t.integer :situation_nombre_annee_vacances
      t.string  :situation_siren_dernier_occupant
      t.string  :situation_nom_dernier_occupant
      t.string  :situation_vlf_cfe
      t.boolean :situation_taxation_base_minimum, null: false, default: false

      t.integer :proposition_occupation_annee_concernee
      t.string  :proposition_occupation
      t.date    :proposition_date_occupation
      t.boolean :proposition_erreur_tlv,      null: false, default: false
      t.boolean :proposition_erreur_thlv,     null: false, default: false
      t.boolean :proposition_meuble_tourisme, null: false, default: false
      t.boolean :proposition_majoration_rs,   null: false, default: false
      t.string  :proposition_nom_occupant
      t.string  :proposition_prenom_occupant
      t.string  :proposition_adresse_occupant
      t.string  :proposition_numero_siren
      t.string  :proposition_nom_societe
      t.string  :proposition_nom_enseigne
      t.boolean :proposition_etablissement_principal, null: false, default: false
      t.boolean :proposition_chantier_longue_duree, null: false, default: false
      t.string  :proposition_code_naf
      t.date    :proposition_date_debut_activite
    end
  end
end
