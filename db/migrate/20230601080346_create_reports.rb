# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports, id: :uuid, default: "gen_random_uuid()" do |t|
      t.belongs_to :collectivity, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :publisher,    type: :uuid, null: true,  foreign_key: { on_delete: :cascade }
      t.belongs_to :package,      type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :workshop,     type: :uuid, foreign_key: { on_delete: :nullify }
      t.belongs_to :sibling,      type: :string

      t.timestamps
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :debated_at
      t.datetime :discarded_at

      t.string  :reference, null: false
      t.enum    :action,    null: false, enum_type: "action"
      t.string  :subject,   null: false
      t.boolean :completed, null: false, default: false
      t.boolean :sandbox,   null: false, default: false
      t.enum    :priority,  null: false, enum_type: "priority", default: "low"

      t.index :reference, unique: true
      t.index %i[sibling_id subject],
        unique: true,
        name:   "index_reports_on_subject_uniqueness",
        where:  "discarded_at IS NULL"

      t.string  :code_insee
      t.date    :date_constat
      t.text    :enjeu
      t.text    :observations
      t.text    :reponse

      t.integer :situation_annee_majic
      t.string  :situation_invariant
      t.string  :situation_proprietaire
      t.string  :situation_numero_ordre_proprietaire

      t.string  :situation_parcelle
      t.string  :situation_numero_voie
      t.string  :situation_indice_repetition
      t.string  :situation_libelle_voie
      t.string  :situation_code_rivoli
      t.string  :situation_adresse

      t.string  :situation_numero_batiment
      t.string  :situation_numero_escalier
      t.string  :situation_numero_niveau
      t.string  :situation_numero_porte
      t.string  :situation_numero_ordre_porte

      t.string  :situation_nature
      t.string  :situation_affectation
      t.string  :situation_categorie

      t.float   :situation_surface_reelle
      t.float   :situation_surface_p1
      t.float   :situation_surface_p2
      t.float   :situation_surface_p3
      t.float   :situation_surface_pk1
      t.float   :situation_surface_pk2
      t.float   :situation_surface_ponderee

      t.string  :situation_date_mutation
      t.string  :situation_coefficient_localisation
      t.string  :situation_coefficient_entretien
      t.string  :situation_coefficient_situation_generale
      t.string  :situation_coefficient_situation_particuliere
      t.string  :situation_exoneration

      t.string  :proposition_parcelle
      t.string  :proposition_numero_voie
      t.string  :proposition_indice_repetition
      t.string  :proposition_libelle_voie
      t.string  :proposition_code_rivoli
      t.string  :proposition_adresse

      t.string  :proposition_numero_batiment
      t.string  :proposition_numero_escalier
      t.string  :proposition_numero_niveau
      t.string  :proposition_numero_porte
      t.string  :proposition_numero_ordre_porte

      t.string  :proposition_nature
      t.string  :proposition_nature_dependance
      t.string  :proposition_affectation
      t.string  :proposition_categorie

      t.float   :proposition_surface_reelle
      t.float   :proposition_surface_p1
      t.float   :proposition_surface_p2
      t.float   :proposition_surface_p3
      t.float   :proposition_surface_pk1
      t.float   :proposition_surface_pk2
      t.float   :proposition_surface_ponderee

      t.string  :proposition_coefficient_localisation
      t.string  :proposition_coefficient_entretien
      t.string  :proposition_coefficient_situation_generale
      t.string  :proposition_coefficient_situation_particuliere
      t.string  :proposition_exoneration

      t.string  :proposition_date_achevement
      t.string  :proposition_numero_permis
      t.string  :proposition_nature_travaux
    end
  end
end
